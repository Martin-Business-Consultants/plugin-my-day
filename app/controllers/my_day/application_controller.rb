module MyDay
  # The plugin's pages use the core's layout, and vanish while it's switched off. Everything here is
  # the signed-in person's own: their work, their bundles.
  class ApplicationController < ::ApplicationController
    layout "application"

    before_action { head :not_found unless Runwell::Plugins.enabled?(:my_day) }

    private
      def person = Current.user.person
      def set_bundle = @bundle = Bundle.where(user: person).find(params[:bundle_id] || params[:id])

      # Back to the day as it was: the same filter, search and open todo.
      def back_to_day(todo: params[:todo], bundle: params[:from_bundle], **options)
        redirect_to my_day_day_path({ todo: todo, show: params[:show], q: params[:q], from_bundle: bundle }.compact_blank), **options
      end
  end
end
