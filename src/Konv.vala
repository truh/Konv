/**
* Copyright (c) 2017 SkyzohKey <skyzohkey@konv.im>
*
* MIT License
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
* LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
* WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/

using Konv;
using Konv.Gui;
// using Konv.Core; // Uncomment later once core is ready.

/**
* @class Konv.App - Entrypoint of the application.
**/
namespace Konv {

  public class App : Gtk.Application {

    private static bool display_version = false;
    private static bool show_about = false;
    private const OptionEntry[] OPTIONS = {
      { "version", 'v', 0, OptionArg.NONE, ref display_version, "Display the application version.", null },
      { "about", 'a', 0, OptionArg.NONE, ref show_about, "Show the about window.", null },
      { null } // List terminator
    };

    private List<Gtk.Window> windows;

    /**
    * @private {string} args - The arguments used in this instance.
    **/
    private string[] args = {};

    /**
    *	@public {Konv.Gui.Windows.MainWindow} main_window - The main window used by the app.
    **/
    public Konv.Gui.Windows.MainWindow main_window { get; set; default = null; }

    /**
    * @constructor Konv.App
    * @param {string[]} args - The arguments array to parse.
    **/
    public App (string[] args) {
      GLib.Object (
        application_id: "im.konv.client",
        flags: ApplicationFlags.FLAGS_NONE
      );

      this.args = args;

      this.init_gettext ();
    }

    private void init_gettext () {
      Intl.setlocale (LocaleCategory.MESSAGES, "");
      Intl.textdomain (Konv.Constants.GETTEXT_PACKAGE);
      Intl.bind_textdomain_codeset (Konv.Constants.GETTEXT_PACKAGE, "utf-8");
      Intl.bindtextdomain (Konv.Constants.GETTEXT_PACKAGE, Konv.Constants.GETTEXT_PATH);
    }

    private void init_actions () {
      SimpleAction action_menubar_toggle = new SimpleAction ("toggle-menubar", null);
      action_menubar_toggle.activate.connect ((variant) => {
        if (this.main_window != null) {
          this.main_window.toggle_menubar ();
        }
      });

      SimpleAction action_about = new SimpleAction ("show-about", null);
      action_about.activate.connect ((variant) => {
        if (this.main_window != null) {
          this.main_window.show_about ();
        }
      });

      SimpleAction action_show_preferences = new SimpleAction ("show-preferences", null);
      action_show_preferences.activate.connect ((variant) => {
        if (this.main_window != null) {
          this.main_window.show_preferences ();
        }
      });

      SimpleAction action_show_welcome = new SimpleAction ("show-welcome", null);
      action_show_welcome.activate.connect ((variant) => {
        if (this.main_window != null) {
          this.main_window.show_welcome_screen ();
        }
      });

      this.set_accels_for_action ("app.toggle-menubar", { "<Primary><Ctrl>M" });
      this.set_accels_for_action ("app.show-about", { "<Primary><Ctrl><Shift>H" });
      this.set_accels_for_action ("app.show-preferences", { "<Primary><Ctrl><Shift>P" });
      this.set_accels_for_action ("app.show-welcome", { "<Primary><Ctrl>H" });

      this.add_action (action_menubar_toggle);
      this.add_action (action_about);
      this.add_action (action_show_preferences);
      this.add_action (action_show_welcome);
    }

    public override void activate () {
      /**
       * TODO: Load settings and show app in correct theme variant (dark/white).
       **/
      Gtk.Settings.get_default ().set ("gtk-application-prefer-dark-theme", true);

      this.main_window = new Konv.Gui.Windows.MainWindow (this);
      this.init_actions ();

      if (show_about && this.main_window != null) {
        this.main_window.show_about ();
        return;
      }

      this.main_window.show_all ();
    }

    public static int main (string[] argv) {
      try {
        var opt_context = new OptionContext ("- %s: %s".printf (Konv.Constants.APP_NAME, Konv.Constants.RELEASE_NAME));
        opt_context.set_help_enabled (true);
        opt_context.add_main_entries (OPTIONS, null);
        opt_context.parse (ref argv);
      } catch (OptionError e) {
        print ("error: %s\n", e.message);
        print ("Run '%s --help' to see a full list of available command line options.\n", argv[0]);
        return 1;
      }

      if (display_version) {
        print ("%s version %s-%s\n", Konv.Constants.APP_NAME, Konv.Constants.VERSION, Konv.Constants.VERSION_INFO);
        print ("libtoxcore version %lu.%lu.%lu\n", ToxCore.Version.MAJOR, ToxCore.Version.MINOR, ToxCore.Version.PATCH);
        return 0;
      }

      Konv.App app = new Konv.App (argv);

      try {
        app.register (null);
      } catch (Error e) {
        print (@"Cannot register app. Error: $(e.message)");
      }
      return app.run (argv);
    }
  }
}
