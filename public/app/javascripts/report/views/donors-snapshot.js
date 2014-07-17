'use strict';

define([
  'underscore',
  'underscoreString',
  'backbone',
  'handlebars',
  'views/snapshot/chart',
  'models/report',
  'text!templates/snapshot.handlebars'
], function(_, underscoreString, Backbone, Handlebars, SnapshotChart, ReportModel, tpl) {

  var DonorsSnapshotView = Backbone.View.extend({

    options: {
      limit: 10
    },

    el: '#donorsSnapshotView',

    template: Handlebars.compile(tpl),

    initialize: function() {
      Backbone.Events.on('filters:fetch', this.hide, this);
      Backbone.Events.on('filters:done', this.showSnapshot, this);
    },

    render: function() {
      this.$el.html(this.template(this.data));
    },

    hide: function() {
      this.$el.addClass('is-hidden');
    },

    showSnapshot: function() {
      this.data = {
        title: 'Donors snapshot',
        description: _.str.sprintf('A total of %(donors)s found donors, supporting %(projects)s projects by %(organizations)s organizations in %(countries)s countries across %(sectors)s sectors.', {
          donors: ReportModel.instance.get('donors').length,
          projects: ReportModel.instance.get('projects').length,
          organizations: ReportModel.instance.get('organizations').length,
          countries: ReportModel.instance.get('countries').length,
          sectors: ReportModel.instance.get('sectors').length
        }),
        charts: [{
          name: 'By number of projects',
          series: _.first(_.map(ReportModel.instance.get('donors'), function(donor) {
            return {
              name: donor.name,
              data: [[donor.name, donor.projectsCount]]
            };
          }), this.options.limit)
        }, {
          name: 'By number of organizations',
          series: _.first(_.map(ReportModel.instance.get('donors'), function(donor) {
            return {
              name: donor.name,
              data: [[donor.name, donor.organizationsCount]]
            };
          }), this.options.limit)
        }, {
          name: 'By number of countries',
          series: _.first(_.map(ReportModel.instance.get('donors'), function(donor) {
            return {
              name: donor.name,
              data: [[donor.name, donor.countriesCount]]
            };
          }), this.options.limit)
        }]
      };

      this.render();

      this.setDonorsChart();

      this.$el.removeClass('is-hidden');
    },

    setDonorsChart: function() {
      var $chartElements = this.$el.find('.mod-report-stacked-chart');

      $chartElements.each(_.bind(function(index, element) {
        var options = {
          chart: {
            type: 'column',
            spacingLeft: 0,
            spacingRight: 0,
            width: 206,
            height: (this.data.charts[index].series.length > 3) ? 600 : 250
          },
          series: this.data.charts[index].series
        };

        new SnapshotChart()
          .setElement($(element))
          .setChart(options);
      }, this));
    }

  });

  return DonorsSnapshotView;

});
