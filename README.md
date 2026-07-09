# Vixi's mod!

This is my factorio mod!

# Symlinking

So, Idk if theres a better way to setup your test enviornment but, the way i liked was symlinking into factorio directly to replace the running
mod ver.

```bash
VERSION=$(grep '"version"' ~/git/factorio/vixis-mod/info.json | sed 's/.*: "\(.*\)".*/\1/')
rm -f ~/.factorio/mods/vixis-mod ~/.factorio/mods/vixis-mod_*.zip
cd ~/git/factorio && zip -r ~/.factorio/mods/vixis-mod_${VERSION}.zip vixis-mod -x 'vixis-mod/.git/*'
```