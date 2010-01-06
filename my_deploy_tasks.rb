namespace(:mine) do
  desc 'say something'
  task :say_something do
    puts "Something"
  end
end

namespace :monitor do
  desc "Analyze Rails Log instantaneously" 
  task :pl_analyze, :roles => :app do
    run "pl_analyze #{shared_path}/log/#{rails_env}.log" do |ch, st, data|
      print data
    end
  end

  desc "Run rails_stat" 
  task :rails_stat, :roles => :app do
    stream "rails_stat #{shared_path}/log/#{rails_env}.log" 
  end
    
  desc "Run oink for the environment"
  task :oink, :roles => :app do
    run "cd #{current_path} && script/oink #{shared_path}/log/#{rails_env}.log -t 1" do |ch, st, data|
      puts "#{ch[:server]} -> #{data}"
    end
  end

  
  desc "Tail the Rails log for this environment"
  task :tail_log, :roles => :app do
    run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:server]} -> #{data}" 
      break if stream == :err    
    end
  end

end
