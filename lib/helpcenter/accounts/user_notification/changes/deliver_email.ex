defmodule Helpcenter.Accounts.UserNotification.Changes.DeliverEmail do
  use Ash.Resource.Change
  import Swoosh.Email

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.change_attribute(:processed, true)
    |> Ash.Changeset.after_action(&deliver_email/2)
  end

  def atomic?(), do: true

  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp deliver_email(_changeset, notification) do
    new()
    |> from({"noreply", "noreply@example.com"})
    |> to("noreply@example.com")
    |> subject(notification.subject)
    |> text_body(notification.body)
    |> html_body(body(notification))
    |> Helpcenter.Mailer.deliver!()

    {:ok, notification}
  end

  defp body(notification) do
    """
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset="UTF-8" />
    <title>Welcome to the Team!</title>
    <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f7f9fc;
      margin: 0;
      padding: 0;
      color: #333;
    }
    .container {
      max-width: 600px;
      margin: 30px auto;
      background-color: #ffffff;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
      padding: 30px;
    }
    h1 {
      color: #2c3e50;
    }
    p {
      line-height: 1.6;
    }
    .footer {
      margin-top: 30px;
      font-size: 13px;
      color: #888;
      text-align: center;
    }
    .button {
      display: inline-block;
      margin-top: 20px;
      background-color: #007bff;
      color: white;
      text-decoration: none;
      padding: 12px 20px;
      border-radius: 4px;
    }
    .button:hover {
      background-color: #0056b3;
    }
    </style>
    </head>
    <body>
    <div class="container">
    <h1>Welcome to the Team!</h1>
    <p>Hi <strong>#{"Your names"}</strong>,</p>

    <p>We're thrilled to have you join our team! Your skills, experience, and passion will be a great addition, and we’re excited about the journey ahead.</p>

    <p>Over the next few days, you’ll be introduced to the team, get access to key tools, and receive everything you need to hit the ground running.</p>

    <p>If you have any questions, don’t hesitate to reach out. We’re here to support you every step of the way.</p>

    <a href="#{notification.id}" class="button">Get Started</a>

    <p>Once again, welcome aboard. We can’t wait to see what we’ll achieve together!</p>

    <p>Warm regards,<br/>
    <strong>The #{"Testing team"} Team</strong></p>

    <div class="footer">
      &copy; #{Date.utc_today()} #{"Testing team"}. All rights reserved.
    </div>
    </div>
    </body>
    </html>

    """
  end
end
