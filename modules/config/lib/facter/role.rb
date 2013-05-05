Facter.add("role") do
    setcode do
        host = Facter.value('hostname')
        case host
            when /^www(?!\d).*$/
                "load_balancer"
            when /^www\d+.*$/
                "web_server"
            when /^mysql.*$/
                "db_server"
            else
                "server"
        end
    end
end