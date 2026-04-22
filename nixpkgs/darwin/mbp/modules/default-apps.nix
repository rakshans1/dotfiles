{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.duti ];

  system.activationScripts.postActivation.text = ''
    echo "Setting default apps..."
    sudo -u rakshan ${pkgs.duti}/bin/duti -s com.sublimetext.4 net.daringfireball.markdown all
    sudo -u rakshan ${pkgs.duti}/bin/duti -s com.sublimetext.4 .md all
    sudo -u rakshan ${pkgs.duti}/bin/duti -s com.sublimetext.4 .markdown all

    sudo -u rakshan ${pkgs.duti}/bin/duti -s company.thebrowser.Browser http
    sudo -u rakshan ${pkgs.duti}/bin/duti -s company.thebrowser.Browser https
    sudo -u rakshan ${pkgs.duti}/bin/duti -s company.thebrowser.Browser public.html all
    sudo -u rakshan ${pkgs.duti}/bin/duti -s company.thebrowser.Browser public.xhtml all
  '';
}
