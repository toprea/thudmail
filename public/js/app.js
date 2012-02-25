
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

    $.ajaxSetup({
      headers: {'X-Thudmail-Authtoken': 'user2'}
    });

    this.initTemplates();

    this.router = new ThudRouter();
    Backbone.history.start();

    // load labels
    this.showLabelList();

    // don't blow away an existing hash -- a user might refresh a page
    if (document.location.hash === "") {
      this.router.navigate("INBOX/p1", {trigger: true});
    }

    $('#search').on('click', thud.eventHandlers.search);
  }, 

  showLabelList: function() {
    $.ajax({
      url: '/api/labels',
      success: function(response) {
        console.log('showLabelList: got response');
        var el = $('#label-list');
        el.html(thud.renderTemplate('label-list', response));
      }
    });
  },

  showSearchResults: function(query, page) {
    query = typeof query !== 'undefined' ? query : '';
    page = typeof page !== 'undefined' ? page : '1';
    console.log('showSearchResults ' + query);
    $.ajax({
      url: '/api/search?q=' + query + '&page=' + page,
      success: function(response) {
        console.log('showSeachResults: got response');
        var el = $('#main');
        el.html(thud.renderTemplate('message-list', response));
      }
    });
  },

  showMailbox: function(label, page) {
    label = typeof label !== 'undefined' ? label : 'INBOX';
    page = typeof page !== 'undefined' ? page : '1';

    console.log('showMailbox ' + label);

    $.ajax({
      url: '/api/label/' + label+ '?page=' + page,
      success: function(response) {
        console.log('showMailbox: got response');
        var el = $('#main');
        if (label === 'Sent Mail') {
          response.isSentMail = true;
        }
        el.html(thud.renderTemplate('message-list', response));
      }
    });
  },

  showMessage: function(id) {
    console.log("readMessage: " + id);
    $.ajax({ url: '/api/message/' + id + '/details',
      success: function(response) {
        console.log('showMessage: got response');
        var el = $('#main');
        el.html(thud.renderTemplate('message-details', response));
      }
    });
  },

  templates: {},

  initTemplates: function() {
    //god that's ugly.
    Handlebars.registerHelper('nl2br', function(text) {
      return (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br/>$2');
    });
  },

  getTemplate: function(name) {
    if (!thud.templates[name]) {
      //thud.templates[name] = _.template($('#templates > [name=' + name + ']').text());
      thud.templates[name] = Handlebars.compile($('#templates > [name=' + name + ']').html());
    }
    return thud.templates[name];
  },
  renderTemplate: function(templateName, data) {
    return thud.getTemplate(templateName)(data);
  },
          
  eventHandlers: {
           
    search: function(e) {
      var query = $('#q').val();
      thud.router.navigate('search/' + query + '/p1', {trigger: true});
    }
  }
}





