{
  day-night-plasma-wallpapers = ./day-night-plasma-wallpapers-nixos.nix;
  numworks = ./numworks.nix;
  slick-greeter = ./slick-greeter.nix;
  hmModules = {
    day-night-plasma-wallpapers = ./day-night-plasma-wallpapers-home-manager.nix;
    myvim = ./myvim.nix;
    redshift-auto = ./redshift-auto.nix;
    sync-database = ./sync-database.nix;
    pronotebot = ./pronotebot.nix;
    pronote-timetable-fetch = ./pronote-timetable-fetch.nix;
  };
}

