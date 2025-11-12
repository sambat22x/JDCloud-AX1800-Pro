#!/bin/bash

# 1. CLEAN OUT BLOAT (from the original script)
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-netgear
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-netdata
rm -rf feeds/luci/applications/luci-app-serverchan

# 2. FIX MAKEFILES (from the original script)
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}

# 3. RUN FEEDS UPDATE
./scripts/feeds update -a
./scripts/feeds install -a

#
# -----------------------------------------------------------------
# START: CUSTOM PATCHES (The only ones we want)
# -----------------------------------------------------------------

# --- 1. 1GB RAM PATCH FOR JD CLOUD AX1800 PRO ---
echo "Applying 1GB RAM patch for AX1800 Pro..."
DTS_FILE=$(find ./ -name "ipq6018-jdcloud-ax1800-pro.dts")
if [ -f "$DTS_FILE" ]; then
    echo "Found DTS file at $DTS_FILE"
    sed -i 's/reg = <0x41000000 0x20000000>;/reg = <0x41000000 0x40000S000>;/g' $DTS_FILE
    sed -i 's/\/* 512 MiB \*\//\/* 1024 MiB \*\//g' $DTS_FILE
    echo "1GB RAM patch applied successfully."
else
    echo "WARNING: Could not find the .dts file to patch for 1GB RAM."
fi

# --- 2. CUSTOM LAN IP ADDRESS PATCH (10.1.1.1) ---
echo "Setting custom LAN IP to 10.1.1.1..."
sed -i "s/option ipaddr '192.168.1.1'/option ipaddr '10.1.1.1'/g" package/base-files/files/bin/config_generate
echo "Custom LAN IP set to 10.1.1.1."

# -----------------------------------------------------------------
# END: CUSTOM PATCHES
# -----------------------------------------------------------------
