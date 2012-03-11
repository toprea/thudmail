
$(document).ready(function () {
  thud.init();
});

var ThudRouter = Backbone.Router.extend({
  routes: {
    "login": "login",
    "logout": "logout",
    "search/:query": "search",
    "search/:query/p:page": "search",
    "message/:id": "message",

    // these need to be last
    ":label": "label",
    ":label/p:page": "label"

  },

  login: function() {
    console.log("route: login");
    thud.showLogin();
  },

  logout: function() {
    console.log("route: logout");
    thud.doLogout();
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

    this.initTemplates();

    // if no auth token present, show login screen, otherwise load inbox
    if (localStorage['authToken']) {

      thud.setAuthToken(localStorage['authToken']);

      thud.showStandardLayout();
      
      this.router = new ThudRouter();
      Backbone.history.start();
      if (document.location.hash === "") {
        this.router.navigate("INBOX/p1", {trigger: true});
      }

    } else {
      this.router = new ThudRouter();
      Backbone.history.start();
      this.router.navigate("login", {trigger: true});
    }

  }, 

  showStandardLayout: function() {
    var mainPage = $('#page-container');
    mainPage.html(thud.getTemplateSource('standard-layout'));
    $('#search').on('click', thud.eventHandlers.search);
    thud.showLabelList();
  },

  showLogin: function() {
    console.log("showLogin");
    var mainPage = $('#page-container');
    mainPage.html(thud.getTemplateSource('login-form'));
    $('#btn-login').on('click', thud.eventHandlers.login)
  },

  doLogout: function() {
    console.log("doLogout");
    thud.setAuthToken('');
    this.router.navigate("login", {trigger: true});
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
      url: '/api/labels/' + label+ '?page=' + page,
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
    $.ajax({ url: '/api/messages/' + id + '/details',
      success: function(response) {
        console.log('showMessage: got response');
        var el = $('#main');
        el.html(thud.renderTemplate('message-details', response));
        $('a.attachment-link', el).on('click', thud.eventHandlers.downloadAttachment);
        $('a.raw-link', el).on('click', thud.eventHandlers.downloadRawMessage);
      }
    });
  },

  templates: {},

  initTemplates: function() {
    //god that's ugly.
    Handlebars.registerHelper('nl2br', function(text) {
      return (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br/>$2');
    });
    Handlebars.registerHelper('pick', function(text, defaultText) {
      return (text || defaultText);
    });
    Handlebars.registerHelper('formatDate', function(millis) {
      var d = new Date(millis);
      return d.toDateString();
    });
  },

  getTemplate: function(name) {
    if (!thud.templates[name]) {
      //thud.templates[name] = _.template($('#templates > [name=' + name + ']').text());
      thud.templates[name] = Handlebars.compile(thud.getTemplateSource(name));
    }
    return thud.templates[name];
  },

  getTemplateSource: function(name) {
    return $('#templates > [name=' + name + ']').html()
  },

  renderTemplate: function(templateName, data) {
    return thud.getTemplate(templateName)(data);
  },

  setAuthToken: function(token) {
    console.log('setAuthToken: ' + token)
    localStorage.authToken = token;
    $.ajaxSetup({
      headers: {'X-Thudmail-Authtoken': token}
    });
  },
          
  eventHandlers: {
           
    search: function(e) {
      var query = $('#q').val();
      thud.router.navigate('search/' + query + '/p1', {trigger: true});
    }, 

    login: function(e) {
      var username = $('#tb-username').val();
      var password = $('#tb-password').val();
      $.ajax({
        url: "/api/login",
        type: "POST",
        data: {username: username, password: password},
        success: function(response) {
          console.log("response from login: " + JSON.stringify(response));
          if (response['status'] === 'success') {
            thud.setAuthToken(response['authtoken']);
            thud.showStandardLayout();
            thud.router.navigate("INBOX/p1", {trigger: true});

          } else {
            alert("invalid login.");
          }
        }
      });
    },

    // to download an attachment, we need to first generate a download token
    // by hitting /api/download_token (and sending the current user's auth token)
    // then start the download by appending an iframe whose src is set to the
    // attachment-download url and pass the download token in as a query parameter
    downloadAttachment: function(e) {
      e.preventDefault();
      var messageId = $(this).attr('data-message-id');
      var attachmentIndex = $(this).attr('data-attachment-index');
      console.log("downloadAttachment: " + messageId + " " + attachmentIndex);
      $.ajax({
        url: '/api/download_token',
        success: function(response) {
          console.log("generated token " + JSON.stringify(response));
          var downloadUrl = '/api/messages/' + messageId + '/attachments/' + attachmentIndex + '?token=' + response.token;
          $('body').append('<iframe src="' + downloadUrl + '" style="display:none"></iframe>');
        }
      });
    },

    // same deal as downloading an attachment
    downloadRawMessage: function(e) {
      e.preventDefault();
      var messageId = $(this).attr('data-message-id');
      console.log("downloadRawMessage: " + messageId);
      $.ajax({
        url: '/api/download_token',
        success: function(response) {
          console.log("generated token " + JSON.stringify(response));
          var downloadUrl = '/api/messages/' + messageId + '/raw' + '?token=' + response.token;
          $('body').append('<iframe src="' + downloadUrl + '" style="display:none"></iframe>');
        }
      });
    }
  }
}





