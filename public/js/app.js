
$(document).ready(function () {
    thud.init();
});

var ThudRouter = Backbone.Router.extend({
        routes: {
            "search/:query": "search",
            "search/:query/p:page": "search",
            "message/:id": "message",
            // these need to be last
            ":label": "label",
            ":label/p:page": "label"
            
        },

        label: function(label, page) {
            console.log("route: label");
            thud.showMailbox(label, page)
        },

        search: function(query, page) {
            console.log("route: search");
            thud.showSearchResults(query, page);
        },

        message: function(id) {
            console.log("route: message");
            thud.showMessage(id);
        }
    });

var thud = {
    
    router: {},
    init: function() {
        this.router = new ThudRouter();
        Backbone.history.start();
        this.router.navigate("INBOX", {trigger: true});

        $('#search').on('click', thud.eventHandlers.search);
   }, 

   showSearchResults: function(query, page) {
    query = typeof query !== 'undefined' ? query : '';
    page = typeof page !== 'undefined' ? page : '1';
    console.log('showSearchResults ' + query);
    var template = this.getTemplate('message-list');
    $.ajax({
        url: '/api/search?q=' + query + '&page=' + page,
        success: function(response) {
          console.log('showSeachResults: got response');
          var el = $('#main');
          el.html(thud.renderTemplate('message-list', response));
          //el.on('click', thud.eventHandlers.messagelist);
          }});
      },

      showMailbox: function(label, page) {
          label = typeof label !== 'undefined' ? label : 'INBOX';
          page = typeof page !== 'undefined' ? page : '1';

          console.log('showMailbox ' + label);

          var template = this.getTemplate('message-list');
          $.ajax({
            url: '/api/label/' + label+ '?page=' + page,
            success: function(response) {
               console.log('showMailbox: got response');
               var el = $('#main');
               if (label === 'Sent Mail') {
                   response.isSentMail = true;
               }
               el.html(thud.renderTemplate('message-list', response));
               //el.on('click', thud.eventHandlers.messagelist);
               }});
           },

           showMessage: function(id) {
              console.log("readMessage: " + id);

              $.ajax({
                  url: '/api/message/' + id + '/details',
                  success: function(response) {
                    console.log('showMessage: got response');
                    var el = $('#main');
                    el.html(thud.renderTemplate('message-details', response));
                    }});
                },

                templates: {},
                getTemplate: function(name) {
                  if (!thud.templates[name]) {
                     thud.templates[name] = _.template($('#templates > [name=' + name + ']').text());
                 }
                 return thud.templates[name];
             },
             renderTemplate: function(templateName, data) {
              return thud.getTemplate(templateName)(data);
          },
          
          eventHandlers: {
            //  messagelist: function(e) {
            //     // message row divs
            //     var row = $(e.target).closest('.message');
            //     if (row.length > 0) {
            //         var id = row.attr('data-message-id');
            //         console.log('messagelist event: clicked row ' + id);
            //         thud.showMessage(id);
            //     }
            // },
            search: function(e) {
                // message row divs
                var query = $('#q').val();
                thud.router.navigate('search/' + query, {trigger: true});
            }
        }
    }





