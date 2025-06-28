# sk_damages
Made by SK Official
# FiveM Damage Viewer with Webhook (QB/OX)

A FiveM damage viewer tool that supports QBCore and ox_core, with damage logging to a Discord webhook.

## Features

* **Damage Logging**: Records player bullet damage data, including the weapon used, the bone hit, and the amount of damage.
* **Framework Compatibility**: Seamlessly works with both QBCore and ox_core by automatically detecting which framework is started.
* **Discord Webhook**: Sends damage logs to Discord via a webhook for easy monitoring.
* **3D Injured Text**: Players who are injured will display a 3D text above their head: "(( Has been injured /damages [ID] to view the injured. ))".
* **In-Game Command**: Use `/damages [ID]` to view the damage history for a specified player.

## Installation

1.  **Download**: Download the files from GitHub and extract them into your FiveM server's `resources` folder.
2.  **Set up Webhook**:
    * Open the `server.lua` file.
    * Locate the line `local webhookUrl = "https://discord.com/api/webhooks/XXXXXXXXXX/XXXXXXXXXX"`.
    * Replace `https://discord.com/api/webhooks/XXXXXXXXXX/XXXXXXXXXX` with your Discord webhook URL.
3.  **Add to `server.cfg`**: Add `ensure sk_damages` (or your chosen folder name) to your `server.cfg` file.
4.  **Restart Server**: Restart your FiveM server.

## Usage

* When a player takes bullet damage, the damage information will be logged and sent to the Discord webhook you configured.
* Players who are injured (low health) will have a 3D text appear above their head indicating "(( Has been injured /damages [ID] to view the injured. ))".
* **View Damage History**: In-game, use the command `/damages [Player ID]` to view the recent damage details the specified player has taken in the chat.

## Credits

* Developed by SK Official

## Support

If you encounter any issues or have suggestions, please open an issue on GitHub or contact the developer.
