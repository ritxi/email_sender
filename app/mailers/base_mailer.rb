RAILS_ROOT = File.join(File.dirname(__FILE__),'..', '..')
VIEWS_ROOT = File.join(RAILS_ROOT,'app','views')
p VIEWS_ROOT
require 'rubygems'
require "bundler"
require 'benchmark'
require 'ostruct'

Bundler.setup
require File.join(RAILS_ROOT,'lib','utils')
require 'action_mailer'

require 'action_view'
ActionMailer::Base.view_paths = "./app/views/"
require 'haml'
require 'haml/template/plugin'
require 'json'

class BaseMailer < ActionMailer::Base
  class << self
    def method_missing(method_name, options)
      mailer_name = self.name.underscore
      file = File.join(VIEWS_ROOT, mailer_name,"#{method_name}.haml")
      if File.exist?(file)
        self.send_email_message(options)
      else
        super
      end
    end

    def use_production
      options = HashWithIndifferentAccess.new({
                  openssl_verify_mode: 'none',
                  port: '25',
                  authentication: 'plain'
                }).with_indifferent_access
      options.merge(email_config['production'])
      ActionMailer::Base.smtp_settings = options
    end

    def use_test
      ActionMailer::Base.smtp_settings = {
        :address => 'localhost',
        :port => '1025'
      }
    end

    def email_config
      @config ||= Psych.load(File.read(config_file))
    end

    def config_file
      @config_file ||= File.expand_path("~/.email_sender/#{name.underscore}.yml")
    end
  end

  def send_email_message(options)
    raise "Subject can't be blank" if options.subject.blank?
    if options.attachments.any?
      options.attachments.each do |attachement_name, file_name|
        attachments[attachement_name] = afegir_adjunts(file_name)
      end
    end

    mail(to: options.email, subject: options.subject) do |format|
      format.html {
        render(options.method_name.to_s,
          locals: { email: options.email, options: options.options})
      }
    end
  end

  private
  def afegir_adjunts(filename)
    name = /(.+)Mailer$/.match(self.class.name)
    File.read(File.join(RAILS_ROOT,'public','adjunts',name[1].underscore ,filename))
  end
end

def envia(plantilla_mail, socis, &bloc)
  puts socis.count
  @enviaments_fallits = []

  if block_given?
    @options = OpenStruct.new(subject: '', email: '', method_name: plantilla_mail, attachments: {}, options: {})
    yield(@options)
    socis.each_index do |index|
      begin
        socis[index].tap{|soci|
          puts "#{index} - #{soci}"
          #if index >= 151
            @options.email = soci
            AncMailer.send(plantilla_mail, @options).deliver
            wait(Random.new.rand(2..3))
          #end
        }
      rescue => e
        puts e.message
        @enviaments_fallits << socis[index]
      end
    end
  end
end

def local_execute cmd
  IO.popen(cmd) do |f|
    output = f.read
    exitcode = Process.waitpid2(f.pid)[1] >> 8
    {:output => output.chop.split("\n"), :exitcode => exitcode }
  end
end

def wait(segons)
  local_execute("sleep #{segons}")
end