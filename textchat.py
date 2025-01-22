from textual.app import App, ComposeResult
from textual.containers import Container
from textual.widgets import Static, Footer
from textual.reactive import reactive


class ChatBox(Static):
    """A chat box widget for displaying messages."""
    def __init__(self, sender: str, message: str, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.sender = sender
        self.message = message

    def compose(self) -> ComposeResult:
        yield Static(f"[bold]{self.sender}:[/bold]", classes="sender")
        yield Static(self.message, classes="message")


class ModelFooter(Footer):
    """Custom footer to display the model name."""
    def __init__(self, model_name: str, **kwargs):
        super().__init__(**kwargs)
        self.model_name = model_name

    def compose(self) -> ComposeResult:
        yield Static(f"Model: {self.model_name}", classes="footer-text")


class ChatApp(App):
    CSS = """
    Screen {
        layout: vertical;
        align: center middle;
        padding: 2;
        background: #1e1e2e;
    }

    Container {
        width: 90%;
        height: 80%;
        border: round #5c5cff;
        background: #2e2e3e;
        overflow: auto;
    }

    ChatBox {
        padding: 1 2;
        margin: 1;
        border: round #7a7aff;
        background: #333344;
        width: 100%;
    }

    .sender {
        color: #ffffff;
        margin-bottom: 1;
    }

    .message {
        color: #cccccc;
    }

    Footer {
        height: auto;
        background: #7a7aff;
        color: #ffffff;
        text-align: center;
    }

    .footer-text {
        text-align: center;
        color: #ffffff;
    }
 """

    model_name = reactive("microsoft/phi-4")

    def compose(self) -> ComposeResult:
        """Create the layout for the app."""
        yield Container(
            ChatBox("Human", "can you tell me what this means:\n\nOrice papleacă flaușat poa să se reinventeze de la o viață la alta. \nȘmecherește e să te recompui în carnea în care ești."),
            ChatBox("AI", "This is Romanian, and it roughly translates to:\n\nAny fuzzy weakling can reinvent themselves from one life to another.\nThe clever thing is to recompose yourself within the flesh you’re in.\n\nThe message contrasts two approaches to change or growth: one that happens over time or between different phases of life (suggesting it's easy or less impressive) versus one that occurs within your current circumstances, which is presented as more skillful or admirable. It carries a tone of challenge and a sense of resilience."),
        )
        yield ModelFooter(self.model_name)


if __name__ == "__main__":
    ChatApp().run()
