module MyDay
  # One prompt for a local AI to work through several pieces of work, one at a time: what to do
  # with them, then each todo's own brief (the core's Todo::Brief), in the order they were picked.
  # Copied by the bulk bar's Copy for AI (bulk_copy), as text.
  class BriefsController < ApplicationController
    allow_staff
    agent_exempt :index, reason: "A prompt for the person to paste into their own AI; agents read each todo's brief with brief_work."

    LIMIT = 25

    def index
      ids = Array(params[:ids]).map(&:to_i).uniq.first(LIMIT)
      todos = Todo.where(id: ids).includes(:owner, :scope_item, { assignments: :user }, engagement: :client).index_by(&:id).values_at(*ids).compact
      render plain: prompt(todos), content_type: "text/plain"
    end

    private
      def prompt(todos)
        briefs = todos.each_with_index.map do |todo, index|
          "---\n\n## #{index + 1} of #{todos.size}\n\n" + Todo::Brief.new(todo, base_url: request.base_url, person: Current.user).to_s.sub(/\A# /, "### ")
        end
        <<~TEXT + briefs.join("\n")
          # Work through #{todos.size} #{"piece".pluralize(todos.size)} of work, one at a time

          Below are #{todos.size} pieces of work from Runwell, each with its own brief. Do them in this order, one at a time:

          1. Read the brief, then do the work it describes.
          2. Report back as the brief says (its status, and a note of what you did) before you start the next.
          3. If one can't be done (it needs a person, access you don't have, or a decision), mark it blocked with a note saying why, and move on to the next.
          4. When you've been through them all, give a short summary: what's done, what's in review, what's blocked and why.

        TEXT
      end
  end
end
