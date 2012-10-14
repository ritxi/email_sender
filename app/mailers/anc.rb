# encoding : utf-8
require File.expand_path('../base_mailer', __FILE__)

class AncMailer < BaseMailer
  default :from => 'sabadell@assemblea.cat',
          :return_path => 'sabadell@assemblea.cat'

end

#AncMailer.use_production
AncMailer.use_test

mails = %w(ricard@forniol.cat)

envia(:memorial_companys_2012, mails) do |options|
  options.subject = "Homenatge a Lluís Companys a Sabadell"
end

#envia(:responsables_autocar, responsables_autocars) do |options|
#  options.subject = "Instruccions per als responsables dels autocars"
#  options.attachments['Annex-aparcaments.pdf'] = 'Annex-aparcaments.pdf'
#end

#@subject = "IMPORTANT: Canvis detalls autocar"
#
#envia(:autocars_dimarts, autocars1) do |options|
#  options.subject = @subject
#  options.options = {autocar: 1}
#end

#envia('convocatoria_fes', mails) do |options|
#  options.attachments['convocatoria_fes.jpg'] = 'convocatoria_fes.jpg'
#  options.subject = "SBDxI: Fira de joves"
#end