require "cfclogger"

export CFCEntityLimits
CFCEntityLimits = {}
CFCEntityLimits.Logger = CFCLogger "CFCEntityLimits"

include "utils.lua"
include "storage.lua"
include "limiter.lua"
