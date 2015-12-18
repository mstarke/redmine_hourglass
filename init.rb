require File.join File.dirname(__FILE__), 'lib', 'chronos.rb'

Redmine::Plugin.register :redmine_chronos do
  name 'Redmine Chronos plugin'
  description 'Control your time like the god you think you are'
  url 'https://github.com/hicknhack-software/redmine_chronos'
  author 'HicknHack Software GmbH'
  author_url 'http://www.hicknhack-software.com'
  version File.read File.join 'plugins', 'redmine_chronos', '.plugin_version'

  requires_redmine version_or_higher: '3.0.0'

  settings default: {
      report_title: 'Report',
      report_logo_url: '',
      report_logo_width: '150',
      round_minimum: '0.25',
      round_limit: '50',
      round_carry_over_due: '12',
      round_default: false
  }, :partial => 'settings/chronos'

  project_module :redmine_chronos do
    def with_foreign(*permissions)
      permissions.map { |x| [x, "#{x}_foreign".to_sym] }.flatten
    end

    permission :chronos_track_time,
               {
                   :'chronos/time_trackers' => [:start, :update, :stop],
                   :'chronos/time_logs' => [:update, :split, :combine],
                   :'chronos_ui' => [:index]
               },
               require: :loggedin

    permission :chronos_view_tracked_time,
               {
                   :'chronos/time_trackers' => with_foreign(:index, :show),
                   :'chronos/time_logs' => with_foreign(:index, :show),
                   :'chronos_ui' => [:index, *with_foreign(:time_logs)]
               }, require: :loggedin

    permission :chronos_view_own_tracked_time,
               {
                   :'chronos/time_trackers' => [:index, :show],
                   :'chronos/time_logs' => [:index, :show],
                   :'chronos_ui' => [:index, :time_logs]
               }, require: :loggedin

    permission :chronos_edit_tracked_time,
               {
                   :'chronos/time_trackers' => with_foreign(:update, :update_time, :destroy),
                   :'chronos/time_logs' => with_foreign(:update, :update_time, :split, :combine, :destroy),
                   :'chronos_ui' => with_foreign(:edit_time_logs)
               }, require: :loggedin

    permission :chronos_edit_own_tracked_time,
               {
                   :'chronos/time_trackers' => [:update, :update_time, :destroy],
                   :'chronos/time_logs' => [:update, :update_time, :split, :combine, :destroy],
                   :'chronos_ui' => [:edit_time_logs]
               }, require: :loggedin

    permission :chronos_book_time,
               {
                   :'chronos/time_logs' => with_foreign(:book),
                   :'chronos/time_bookings' => with_foreign(:update),
                   :'chronos_ui' => with_foreign(:book_time_logs)
               }, require: :loggedin

    permission :chronos_book_own_time,
               {
                   :'chronos/time_logs' => [:book],
                   :'chronos/time_bookings' => [:update],
                   :'chronos_ui' => [:book_time_logs]
               }, require: :loggedin

    permission :chronos_view_booked_time,
               {
                   :'chronos/time_bookings' => with_foreign(:index, :show),
                   :'chronos_ui' => [:index, *with_foreign(:report, :time_bookings)]
               }, require: :member

    permission :chronos_view_own_booked_time,
               {
                   :'chronos/time_bookings' => [:index, :show],
                   :'chronos_ui' => [:index, :report, :time_bookings]
               }, require: :loggedin

    permission :chronos_edit_booked_time,
               {
                   :'chronos/time_bookings' => with_foreign(:update, :update_time, :destroy),
                   :'chronos_ui' => with_foreign(:edit_time_bookings)
               }, require: :loggedin

    permission :chronos_edit_own_booked_time,
               {
                   :'chronos/time_bookings' => [:update, :update_time, :destroy],
                   :'chronos_ui' => [:edit_time_bookings]
               }, require: :loggedin
  end

  menu :top_menu, :chronos_root, :chronos_root_path, caption: :'chronos.ui.menu.main', if: proc { User.current.allowed_to_globally? controller: 'chronos_ui', action: 'index' }
  #menu :project_menu, :chronos_main_menu, chronos_root_path, caption: 'test'

  Redmine::MenuManager.map :chronos_menu do |menu|
    menu.push :chronos_overview, :chronos_root_path, caption: :'chronos.ui.menu.overview', if: proc { User.current.allowed_to_globally? controller: 'chronos_ui', action: 'index' }
    menu.push :chronos_time_logs, :chronos_ui_time_logs_path, caption: :'chronos.ui.menu.time_logs', if: proc { User.current.allowed_to_globally? controller: 'chronos_ui', action: 'time_logs' }
    menu.push :chronos_time_bookings, :chronos_ui_time_bookings_path, caption: :'chronos.ui.menu.time_bookings', if: proc { User.current.allowed_to_globally? controller: 'chronos_ui', action: 'time_bookings' }
  end
end
