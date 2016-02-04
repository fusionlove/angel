def deploy(phase_yml)
  threads = []
  system 'git add .'
  system "git commit -m 'deploy'"
  phase_yml['environments'].each do |env|
   threads << Thread.new do

     cmd = "eb deploy "+env['name'] #{env['name']}""
     puts cmd
     system cmd
   end
 end
 threads.each {|t| t.join}
end


def update_env(client,e_name, var_string)
  r = client.update_environment({environment_name: e_name,
  option_settings: [
    {
      namespace: "aws:cloudformation:template:parameter",
      option_name: "EnvironmentVariables",
      value: var_string
    }
    ]
  })
end

def update_config(client,e_name,options)
  puts 'Updating config for '+e_name+' to '+options.inspect
  r = client.update_environment({environment_name: e_name,
  option_settings: options
  })
end

def convert_options(mapping,options)
  #Converts developer-friendly options to AWS-friendly options
  #according to a provided mapping
  aws_options = []
  options.keys.each { |opt|
    if mapping.include?(opt)
      link = mapping[opt]
      setting = {namespace: link['namespace'], option_name: link['option_name'], value: options[opt]}
      aws_options << setting
    end
  }
  return aws_options
end


def gen_env_string(vars)
  str = ''
  vars.keys.each {|k|
    str=str+k+'='+vars[k]+','
  }
  str.chomp(',')
end

def set_env_vars(client,environments,variables)
  var_string = gen_env_string(variables)
  environments.each { |e|
    puts 'Setting env vars for '+e['name']
    update_env(client,e['name'],var_string)
  }
end

def create_app_stack(client,phase_dict)
  create_application(client,phase_dict['name'])
  #create_application_version(client,phase_dict['name'])
  threads = []
  phase_dict['environments'].each do |env|
   threads << Thread.new do
     create_environment(client,phase_dict['name'],env['name'],env['tier'])
   end
 end
 threads.each {|t| t.join}
end

def create_application(client,app_name)
  client.create_application({
    application_name: app_name
    })
end


def create_environment(client,app_name,env_name, tier)
  puts 'Create environment '+env_name+', tier: '+tier
  if tier == 'Worker' || tier == 'worker'
    tier_dict = {
      name: 'Worker',
      type: 'SQS/HTTP',
      version:'1.1'
    }
  elsif tier == 'web' || tier == 'Web'
    tier_dict = {
      name: 'WebServer',
      type: 'Standard',
      #version:'1.1'
    }
  end

  client.create_environment({
    application_name: app_name,
    environment_name: env_name,
    cname_prefix: app_name.downcase,
    tier: tier_dict,
    #template_name: env_name,
    solution_stack_name: '64bit Amazon Linux 2015.09 v2.0.6 running Ruby 2.2 (Puma)'
      })
end

def create_application_version(client,app_name)
  puts 'Creating application version...'
  client.create_application_version({
    application_name: app_name,
    version_label: Time.now.to_s,
    auto_create_application: false,
    process: true,
    })
end

def describe_application(client,phase_dict)
  threads = []

  phase_dict['environments'].each do |env|
     threads << Thread.new do
      puts client.describe_environments(environment_names: [ env['name'] ] ).inspect
      puts "\r"
    end

  end
  threads.each do |t|
    t.join
  end
end
