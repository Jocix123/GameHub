/*
This file is part of GameHub.
Copyright (C) 2018-2019 Anatoliy Kashkin

GameHub is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GameHub is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GameHub.  If not, see <https://www.gnu.org/licenses/>.
*/

using Gtk;
using Granite;
using GameHub.Utils;
using GameHub.UI.Widgets;

namespace GameHub.UI.Dialogs.SettingsDialog.Tabs
{
	public class Humble: SettingsDialogTab
	{
		private Settings.Auth.Humble humble_auth;
		private Box enabled_box;
		private Button logout_btn;
		private FileChooserEntry games_dir_chooser;

		public Humble(SettingsDialog dlg)
		{
			Object(orientation: Orientation.VERTICAL, dialog: dlg);
		}

		construct
		{
			var paths = FSUtils.Paths.Settings.get_instance();

			humble_auth = Settings.Auth.Humble.get_instance();

			enabled_box = add_switch(_("Enabled"), humble_auth.enabled, v => { humble_auth.enabled = v; update(); dialog.show_restart_message(); });

			add_separator();

			add_switch(_("Load games from Humble Trove"), humble_auth.load_trove_games, v => { humble_auth.load_trove_games = v; update(); dialog.show_restart_message(); });

			add_separator();

			games_dir_chooser = add_file_chooser(_("Games directory"), FileChooserAction.SELECT_FOLDER, paths.humble_games, v => { paths.humble_games = v; update(); dialog.show_restart_message(); }).get_children().last().data as FileChooserEntry;

			add_separator();

			logout_btn = new Button.with_label(_("Logout"));
			logout_btn.halign = Align.END;
			add_widget(logout_btn);

			logout_btn.clicked.connect(() => {
				humble_auth.authenticated = false;
				humble_auth.access_token = "";
				update();
				dialog.show_restart_message();
			});

			update();
		}

		private void update()
		{
			this.foreach(w => {
				if(w != enabled_box) w.sensitive = humble_auth.enabled;
			});
			logout_btn.sensitive = humble_auth.enabled && humble_auth.authenticated && humble_auth.access_token.length > 0;

			if(" " in FSUtils.Paths.Settings.get_instance().humble_games)
			{
				games_dir_chooser.get_style_context().add_class(Gtk.STYLE_CLASS_ERROR);
			}
			else
			{
				games_dir_chooser.get_style_context().remove_class(Gtk.STYLE_CLASS_ERROR);
			}
			dialog.update_games_dir_space_message();
		}

	}
}
