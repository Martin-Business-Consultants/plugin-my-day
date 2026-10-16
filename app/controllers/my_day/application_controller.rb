module MyDay
  # The plugin's pages use the core's layout, and vanish while it's switched off. Everything here is
  # the signed-in person's own: their work, their priorities.
  class ApplicationController < ::ApplicationController
    layout "application"

    before_action { head :not_found unless Runwell::Plugins.enabled?(:my_day) }

    private
      def person = Current.user.person

      def load_day(todo_id = params[:todo])
        @day = Day.new(person, show: params[:show], query: params[:q])
        @todo = @day.find(todo_id) || @day.first
      end

      # Back to the day as it was: the same filter, search and open todo, which Turbo morphs in
      # place. A drag and drop (the core's drag-and-drop controller posts, asking for a turbo
      # stream) gets a refresh of the page; without a request id, so Turbo doesn't skip it as an
      # echo of its own request. The priorities stay unfolded after a change to them.
      def back_to_day(todo: params[:todo], **options)
        session[:my_day_open] = true if @priorities_open
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
          format.any { redirect_to my_day_day_path({ todo: todo, show: params[:show], q: params[:q] }.compact_blank), **options }
        end
      end
  end
end
