class Actions::ActionButtonsComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
    @items = build_items
  end

  private

  attr_reader :item, :items

  def build_items
    [
      { text: "Show", url: Rails.application.routes.url_helpers.to_do_item_path(item), icon: "eye" },
      { text: "Edit", url: Rails.application.routes.url_helpers.edit_to_do_item_path(item), icon: "edit" }
    ]
  end
end
