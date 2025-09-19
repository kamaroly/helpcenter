# lib/helpcenter/workers/email_sender.ex
defmodule Helpcenter.Workers.EmailSender do
  use Oban.Worker, queue: :default
  import Swoosh.Email

  @impl Oban.Worker
  def perform(job) do
    params = job.args["params"]

    new()
    |> from({"Helpcenter", "no-reply@helpcenter.com"})
    |> to(params["to"] |> to_string())
    |> subject(params["subject"])
    |> html_body(params["body"])
    |> text_body(params["text"])
    |> Helpcenter.Mailer.deliver!()

    :ok
  end
end
