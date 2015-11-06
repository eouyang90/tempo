var ActivitiesView = Backbone.View.extend({
    el: ".testDiv",
    tagName : 'ul',
    options: null,
    time: null,
    interests: [],
    activities : null,
    initialize: function(options){
      this.options = options;
      this.activities = new Activities();
      _.bindAll(this, "renderItem");
    },
    renderItem: function(model){
        var activityView = new ActivityView({model: model});
        activityView.render();
        $(this.el).append(activityView.el);
    },
    render : function (options){
      // Set scope, construct new activity collection, call fetch, render data on callback function
      var that = this; // To fix callback scoping error

      var renderData = function(data) {
        $(that.el).html("<h4 style='color: #9b59b6;'> Activity List </h4> <br>");
        that.activities.each(that.renderItem);
        //TODO: Create and import handlebars for templating     
        // var html = "<h4 style='color: #9b59b6;'> Activity List </h4> <br>"
        //       + "<table> <thead> <tr> <th>Title</th> <th>Content</th> <th>Completion Time</th> <th>Content type</th> <th>Id</th> "
        //       + "<th colspan='3'></th> </tr> </thead>" 
        //       + " <tbody> ";

        // //Iterate throught he collections of Activities and create a template
        // that.activities.each(function(model){
        //   html += "<tr>" 
        //       + "<td> " +  model.get('title') + " </td>"
        //       + "<td> " +  model.get('content') + " </td>"
        //       + "<td> " +  model.get('completion_time') + " </td>"
        //       + "<td> " +  model.get('content_type') + " </td>"
        //       + "<td> " +  model.get('id') + " </td>"
        //     + "</tr>";  
        // });
        // html += " </tbody> </table> </br> ";
        // //Adding activity link
        // html += " <a href='/activities#show' id='add'> Add activity </a>";
        // $(that.el).html(html);  

      };

      //TODO: Find better way to do this
      if(this.interests != [] && this.time){
        this.activities.fetch({
            success: function(data){
            renderData(data);
          },
          dataType: "json",
          data: {"interests": this.interests, "time": this.time}
        });
      } else if (this.interests){
          this.activities.fetch({
            success: function(data){
            renderData(data);
          },
          dataType: "json",
          data: {"interests": this.interests}
        });
      } else if (this.time){
        this.activities.fetch({
          success: function(data){
          renderData(data);
        },
        dataType: "json",
        data: {"time": this.time}
      });
      } else {
        this.activities.fetch({
          success: function(data){
          renderData(data);
        }
      });
      }
    }
  });
