# Vixi's mod!

This is my factorio mod!

# Symlinking

So, Idk if theres a better way to setup your test enviornment but, the way i liked was symlinking into factorio directly to replace the running
mod ver.

```bash
VERSION=$(grep '"version"' ~/git/Factorio/vixis-mod/info.json | sed 's/.*: "\(.*\)".*/\1/')
rm -f ~/.factorio/mods/vixis-mod; find ~/.factorio/mods -maxdepth 1 -name 'vixis-mod_*.zip' -delete
cd ~/git/Factorio && zip -r ~/.factorio/mods/vixis-mod_${VERSION}.zip vixis-mod -x 'vixis-mod/.git/*' 'vixis-mod/tools/*' 'vixis-mod/graphics/entity/load-shed-breaker/[0-9][0-9][0-9][0-9].png'
```