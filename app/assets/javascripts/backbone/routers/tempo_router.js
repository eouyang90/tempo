
var TempoRouter = Backbone.Router.extend({
    routes: {
      '': 'home',
      'home': 'home',
      'signup': 'signup',
      'login': 'login',
      "interests": "interests",
      "activities": "activities",
      "settings":"settings",
      "customActivities": "customActivities",
      "createCustomActivity": "createCustomActivity",
      "activities/:activity":"activity",
      "show": "show"
    },
    verifyUser: function(view) {
      console.log("Verify USer Called");
      var cookie = Cookies.get("login-token");
      var token = new Token();
      token.url += cookie;
      var response = {
        "status": false,
        "data": ""
      };
      if (cookie === "undefined" || cookie === undefined) {
        console.log('undefined');
        return this.renderView("login", "");
      } else {
        var that = this;
        token.fetch({
            success: function(data){
              that.renderView(view, data)
          }, 
            failure: function(data) {
            return that.renderView("login", "");
          }
      });
      }
    },
    renderView : function(view, data) {
      if (view === "login") {
        Backbone.history.navigate('login');  
        App.Views['loginView'].render();
      } else {
        var userData = data.attributes.user;
        var user = new User();
        user.username = userData.username;
        user.password = userData.password;
        user.id = userData.id;
        user.email = userData.email;
        user.name = userData.name;
        user.interests = userData.interests;
        App.Views[view].render({
            "user" : user
        });
      }
    },
    initialize: function() {
      App.Views['interestView'] = new InterestView()
      App.Views['customActivityView'] = new CustomActivityView()
      App.Views['createCustomActivityView'] = new CreateCustomActivityView()
      App.Views['activitiesView'] = new ActivitiesView();
      App.Views['settingsView'] = new SettingsView();
      App.Views['loginView'] = new LoginView();
      App.Views['homeView'] = new HomeView({interestView: App.Views['interestView'],
                                activitiesView: App.Views['activitiesView']});
    },
    home: function() {
      console.log("The home router was called ");
      console.log(this.verifyUser("homeView"));
      this.verifyUser("homeView");

    },
    activities: function(){
      console.log("The activities router was called ");
      this.verifyUser("activitiesView");
   
    },
    activity: function(activity_id) {
      console.log("The activity router was called");
      console.log(activity_id);
      App.Views['activityView']= new ActivityView({id:activity_id});
      this.verifyUser("activityView");
    },
    interests: function(){
      console.log("The interests router was called ");
      this.verifyUser("interestView");
     
    },
    settings: function(){
      console.log("The settings router was called ");
      this.verifyUser("settingsView");
     
    },
    customActivities: function(){
      console.log("The custom Activities router was called ");
      this.verifyUser("customActivityView");     
    },    
    createCustomActivity: function(){
      console.log("Creating a custom activity");
      this.verifyUser("createCustomActivityView");
    },
    signup: function(){
      console.log("The signup router was called ");
      //Constructing View 
      App.Views['signupView'] = new SignupView()
      App.Views['signupView'].render()      
    },
    login: function(){
      console.log("The login router was called ");
      //Constructing View 
      App.Views['loginView'].render()      
    },

  });