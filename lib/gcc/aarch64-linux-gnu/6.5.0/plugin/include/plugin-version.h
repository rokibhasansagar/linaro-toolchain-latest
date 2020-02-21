#include "configargs.h"

#define GCCPLUGIN_VERSION_MAJOR   6
#define GCCPLUGIN_VERSION_MINOR   5
#define GCCPLUGIN_VERSION_PATCHLEVEL   0
#define GCCPLUGIN_VERSION  (GCCPLUGIN_VERSION_MAJOR*1000 + GCCPLUGIN_VERSION_MINOR)

static char basever[] = "6.5.0";
static char datestamp[] = "20181026";
static char devphase[] = "";
static char revision[] = "[linaro-6.5-2018.12 revision 47e9c571cb47061500110bf74c9206735ab8f6dd]";

/* FIXME plugins: We should make the version information more precise.
   One way to do is to add a checksum. */

static struct plugin_gcc_version gcc_version = {basever, datestamp,
						devphase, revision,
						configuration_arguments};
