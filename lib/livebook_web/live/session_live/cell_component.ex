defmodule LivebookWeb.SessionLive.CellComponent do
  use LivebookWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="flex flex-col relative"
      data-element="cell"
      id="cell-<%= @cell_view.id %>"
      phx-hook="Cell"
      data-cell-id="<%= @cell_view.id %>"
      data-type="<%= @cell_view.type %>"
      data-session-path="<%= Routes.session_path(@socket, :page, @session_id) %>">
      <%= render_cell_content(assigns) %>
    </div>
    """
  end

  def render_cell_content(%{cell_view: %{type: :markdown}} = assigns) do
    ~L"""
    <div class="mb-1 flex items-center justify-end">
      <div class="relative z-10 flex items-center justify-end space-x-2" data-element="actions">
        <%= render_cell_anchor_link(assigns) %>
        <span class="tooltip top" aria-label="Edit content" data-element="enable-insert-mode-button">
          <button class="icon-button">
            <%= remix_icon("pencil-line", class: "text-xl") %>
          </button>
        </span>
        <span class="tooltip top" aria-label="Insert image" data-element="insert-image-button">
          <%= live_patch to: Routes.session_path(@socket, :cell_upload, @session_id, @cell_view.id),
                class: "icon-button" do %>
            <%= remix_icon("image-add-line", class: "text-xl") %>
          <% end %>
        </span>
        <span class="tooltip top" aria-label="Move up">
          <button class="icon-button"
            phx-click="move_cell"
            phx-value-cell_id="<%= @cell_view.id %>"
            phx-value-offset="-1">
            <%= remix_icon("arrow-up-s-line", class: "text-xl") %>
          </button>
        </span>
        <span class="tooltip top" aria-label="Move down">
          <button class="icon-button"
            phx-click="move_cell"
            phx-value-cell_id="<%= @cell_view.id %>"
            phx-value-offset="1">
            <%= remix_icon("arrow-down-s-line", class: "text-xl") %>
          </button>
        </span>
        <span class="tooltip top" aria-label="Delete">
          <button class="icon-button"
            phx-click="delete_cell"
            phx-value-cell_id="<%= @cell_view.id %>">
            <%= remix_icon("delete-bin-6-line", class: "text-xl") %>
          </button>
        </span>
      </div>
    </div>

    <div class="flex">
      <div class="w-1 rounded-lg relative -left-3" data-element="cell-focus-indicator">
      </div>
      <div class="w-full">
        <div class="pb-4" data-element="editor-box">
          <%= render_editor(assigns) %>
        </div>

        <div class="markdown" data-element="markdown-container" id="markdown-container-<%= @cell_view.id %>" phx-update="ignore">
          <%= render_markdown_content_placeholder(empty: @cell_view.empty?) %>
        </div>
      </div>
    </div>
    """
  end

  def render_cell_content(%{cell_view: %{type: :elixir}} = assigns) do
    ~L"""
    <div class="mb-1 flex items-center justify-between">
      <div class="relative z-10 flex items-center justify-end space-x-2" data-element="actions" data-primary>
        <%= if @cell_view.evaluation_status == :ready do %>
          <button class="text-gray-600 hover:text-gray-800 focus:text-gray-800 flex space-x-1 items-center"
            phx-click="queue_cell_evaluation"
            phx-value-cell_id="<%= @cell_view.id %>">
            <%= remix_icon("play-circle-fill", class: "text-xl") %>
            <span class="text-sm font-medium">
              <%= if(@cell_view.validity_status == :evaluated, do: "Reevaluate", else: "Evaluate") %>
            </span>
          </button>
        <% else %>
          <button class="text-gray-600 hover:text-gray-800 focus:text-gray-800 flex space-x-1 items-center"
            phx-click="cancel_cell_evaluation"
            phx-value-cell_id="<%= @cell_view.id %>">
            <%= remix_icon("stop-circle-fill", class: "text-xl") %>
            <span class="text-sm font-medium">
              Stop
            </span>
          </button>
        <% end %>
      </div>
      <div class="relative z-10 flex items-center justify-end space-x-2" data-element="actions">
        <%= render_cell_anchor_link(assigns) %>
        <span class="tooltip top" aria-label="Cell settings">
          <%= live_patch to: Routes.session_path(@socket, :cell_settings, @session_id, @cell_view.id), class: "icon-button" do %>
            <%= remix_icon("list-settings-line", class: "text-xl") %>
          <% end %>
        </span>
        <span class="tooltip top" aria-label="Move up">
          <button class="icon-button"
            phx-click="move_cell"
            phx-value-cell_id="<%= @cell_view.id %>"
            phx-value-offset="-1">
            <%= remix_icon("arrow-up-s-line", class: "text-xl") %>
          </button>
        </span>
        <span class="tooltip top" aria-label="Move down">
          <button class="icon-button"
            phx-click="move_cell"
            phx-value-cell_id="<%= @cell_view.id %>"
            phx-value-offset="1">
            <%= remix_icon("arrow-down-s-line", class: "text-xl") %>
          </button>
        </span>
        <span class="tooltip top" aria-label="Delete">
          <button class="icon-button"
            phx-click="delete_cell"
            phx-value-cell_id="<%= @cell_view.id %>">
            <%= remix_icon("delete-bin-6-line", class: "text-xl") %>
          </button>
        </span>
      </div>
    </div>

    <div class="flex">
      <div class="w-1 rounded-lg relative -left-3" data-element="cell-focus-indicator">
      </div>
      <div class="w-full">
        <%= render_editor(assigns) %>

        <%= if @cell_view.outputs != [] do %>
          <div class="mt-2">
            <%= render_outputs(assigns, @socket) %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def render_cell_content(%{cell_view: %{type: :input}} = assigns) do
    ~L"""
    <div class="mb-1 flex items-center justify-end">
      <div class="relative z-10 flex items-center justify-end space-x-2" data-element="actions">
        <%= render_cell_anchor_link(assigns) %>
        <span class="tooltip top" aria-label="Cell settings">
          <%= live_patch to: Routes.session_path(@socket, :cell_settings, @session_id, @cell_view.id), class: "icon-button" do %>
            <%= remix_icon("list-settings-line", class: "text-xl") %>
          <% end %>
        </span>
        <span class="tooltip top" aria-label="Move up">
          <button class="icon-button"
            phx-click="move_cell"
            phx-value-cell_id="<%= @cell_view.id %>"
            phx-value-offset="-1">
            <%= remix_icon("arrow-up-s-line", class: "text-xl") %>
          </button>
        </span>
        <span class="tooltip top" aria-label="Move down">
          <button class="icon-button"
            phx-click="move_cell"
            phx-value-cell_id="<%= @cell_view.id %>"
            phx-value-offset="1">
            <%= remix_icon("arrow-down-s-line", class: "text-xl") %>
          </button>
        </span>
        <span class="tooltip top" aria-label="Delete">
          <button class="icon-button"
            phx-click="delete_cell"
            phx-value-cell_id="<%= @cell_view.id %>">
            <%= remix_icon("delete-bin-6-line", class: "text-xl") %>
          </button>
        </span>
      </div>
    </div>

    <div class="flex">
      <div class="w-1 rounded-lg relative -left-3" data-element="cell-focus-indicator">
      </div>
      <div>
        <form phx-change="set_cell_value" onsubmit="return false">
          <input type="hidden" name="cell_id" value="<%= @cell_view.id %>" />
          <div class="input-label">
            <%= @cell_view.name %>
          </div>
          <input type="text"
            data-element="input"
            class="input <%= if(@cell_view.error, do: "input--error") %>"
            name="value"
            value="<%= @cell_view.value %>"
            spellcheck="false"
            autocomplete="off"
            tabindex="-1" />
          <%= if @cell_view.error do %>
            <div class="input-error">
              <%= String.capitalize(@cell_view.error) %>
            </div>
          <% end %>
        </form>
      </div>
    </div>
    """
  end

  defp render_editor(assigns) do
    ~L"""
    <div class="py-3 rounded-lg bg-editor relative">
      <div
        id="editor-container-<%= @cell_view.id %>"
        data-element="editor-container"
        phx-update="ignore">
        <%= render_editor_content_placeholder(empty: @cell_view.empty?) %>
      </div>

      <%= if @cell_view.type == :elixir do %>
        <div class="absolute bottom-2 right-2">
          <%= render_cell_status(@cell_view.validity_status, @cell_view.evaluation_status) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp render_cell_anchor_link(assigns) do
    ~L"""
    <span class="tooltip top" aria-label="Link">
      <a href="#cell-<%= @cell_view.id %>" class="icon-button">
        <%= remix_icon("link", class: "text-xl") %>
      </a>
    </span>
    """
  end

  # The whole page has to load and then hooks are mounded.
  # There may be a tiny delay before the markdown is rendered
  # or editors are mounted, so show neat placeholders immediately.

  defp render_markdown_content_placeholder(empty: true) do
    assigns = %{}

    ~L"""
    <div class="h-4"></div>
    """
  end

  defp render_markdown_content_placeholder(empty: false) do
    assigns = %{}

    ~L"""
    <div class="max-w-2xl w-full animate-pulse">
      <div class="flex-1 space-y-4">
        <div class="h-4 bg-gray-200 rounded-lg w-3/4"></div>
        <div class="h-4 bg-gray-200 rounded-lg"></div>
        <div class="h-4 bg-gray-200 rounded-lg w-5/6"></div>
      </div>
    </div>
    """
  end

  defp render_editor_content_placeholder(empty: true) do
    assigns = %{}

    ~L"""
    <div class="h-4"></div>
    """
  end

  defp render_editor_content_placeholder(empty: false) do
    assigns = %{}

    ~L"""
    <div class="px-8 max-w-2xl w-full animate-pulse">
      <div class="flex-1 space-y-4 py-1">
        <div class="h-4 bg-gray-500 rounded-lg w-3/4"></div>
        <div class="h-4 bg-gray-500 rounded-lg"></div>
        <div class="h-4 bg-gray-500 rounded-lg w-5/6"></div>
      </div>
    </div>
    """
  end

  defp render_outputs(assigns, socket) do
    ~L"""
    <div class="flex flex-col rounded-lg border border-gray-200 divide-y divide-gray-200 font-editor">
      <%= for {output, index} <- @cell_view.outputs |> Enum.reverse() |> Enum.with_index(), output != :ignored do %>
        <div class="p-4 max-w-full overflow-y-auto tiny-scrollbar">
          <%= render_output(socket, output, "cell-#{@cell_view.id}-output#{index}") %>
        </div>
      <% end %>
    </div>
    """
  end

  defp render_output(_socket, text, id) when is_binary(text) do
    text
    # Captured output usually has a trailing newline that we can ignore,
    # because each line is itself an HTML block anyway.
    |> String.replace_suffix("\n", "")
    |> render_virtualized_output(id, follow: true)
  end

  defp render_output(_socket, {:text, text}, id) do
    render_virtualized_output(text, id)
  end

  defp render_output(_socket, {:vega_lite_static, spec}, id) do
    live_component(LivebookWeb.Output.VegaLiteStaticComponent, id: id, spec: spec)
  end

  defp render_output(socket, {:vega_lite_dynamic, pid}, id) do
    live_render(socket, LivebookWeb.Output.VegaLiteDynamicLive,
      id: id,
      session: %{"id" => id, "pid" => pid}
    )
  end

  defp render_output(_socket, {:error, formatted}, _id) do
    render_error_message_output(formatted)
  end

  defp render_output(_socket, output, _id) do
    render_error_message_output("""
    Unknown output format: #{inspect(output)}. If you're using Kino,
    you may want to update Kino and Livebook to the latest version.
    """)
  end

  defp render_virtualized_output(text, id, opts \\ []) do
    follow = Keyword.get(opts, :follow, false)
    lines = ansi_to_html_lines(text)
    assigns = %{lines: lines, id: id, follow: follow}

    ~L"""
    <div id="<%= @id %>"
      phx-hook="VirtualizedLines"
      data-max-height="300"
      data-follow="<%= follow %>">
      <div data-template class="hidden">
        <%= for line <- @lines do %>
          <div><%= line %></div>
        <% end %>
      </div>
      <div data-content class="overflow-auto whitespace-pre text-gray-500 tiny-scrollbar"
        id="<%= @id %>-content"
        phx-update="ignore"></div>
    </div>
    """
  end

  defp render_error_message_output(message) do
    assigns = %{message: message}

    ~L"""
    <div class="overflow-auto whitespace-pre text-red-600 tiny-scrollbar"><%= @message %></div>
    """
  end

  defp render_cell_status(validity_status, evaluation_status)

  defp render_cell_status(_, :evaluating) do
    render_status_indicator("Evaluating", "bg-blue-500",
      animated_circle_class: "bg-blue-400",
      change_indicator: true
    )
  end

  defp render_cell_status(_, :queued) do
    render_status_indicator("Queued", "bg-gray-500", animated_circle_class: "bg-gray-400")
  end

  defp render_cell_status(:evaluated, _) do
    render_status_indicator("Evaluated", "bg-green-400", change_indicator: true)
  end

  defp render_cell_status(:stale, _) do
    render_status_indicator("Stale", "bg-yellow-200", change_indicator: true)
  end

  defp render_cell_status(:aborted, _) do
    render_status_indicator("Aborted", "bg-red-400")
  end

  defp render_cell_status(_, _), do: nil

  defp render_status_indicator(text, circle_class, opts \\ []) do
    assigns = %{
      text: text,
      circle_class: circle_class,
      animated_circle_class: Keyword.get(opts, :animated_circle_class),
      change_indicator: Keyword.get(opts, :change_indicator, false)
    }

    ~L"""
    <div class="flex items-center space-x-1">
      <div class="flex text-xs text-gray-400">
        <%= @text %>
        <%= if @change_indicator do %>
          <span data-element="change-indicator">*</span>
        <% end %>
      </div>
      <span class="flex relative h-3 w-3">
        <%= if @animated_circle_class do %>
          <span class="animate-ping absolute inline-flex h-3 w-3 rounded-full <%= @animated_circle_class %> opacity-75"></span>
        <% end %>
        <span class="relative inline-flex rounded-full h-3 w-3 <%= @circle_class %>"></span>
      </span>
    </div>
    """
  end
end
