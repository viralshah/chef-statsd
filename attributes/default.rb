default["statsd"]["dir"]                 = "/usr/share/statsd"
default["statsd"]["conf_dir"]            = "/etc/statsd"
default["statsd"]["repository"]          = "git://github.com/etsy/statsd.git"
default["statsd"]["revision_tag"]        = "v0.6.0"
default["statsd"]["log_file"]            = "/var/log/statsd.log"
default["statsd"]["flush_interval"]      = 10000
default["statsd"]["address"]             = "0.0.0.0"
default["statsd"]["port"]                = 8125
default["statsd"]["graphite_host"]       = "localhost"
default["statsd"]["graphite_port"]       = 2003
default["statsd"]["gossip_girl"]         = nil
default["statsd"]["delete_idle_stats"]   = false
default["statsd"]["delete_gauges"]       = false
default["statsd"]["delete_timers"]       = false
default["statsd"]["delete_sets"]         = false
default["statsd"]["delete_counters"]     = false
