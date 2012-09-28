class ProjectMailer
  class NullMailer
    def mail(*args)
    end
  end

  NoCcList = 'none'
  CcList = 'cc'
  BccList = 'bcc'

  ValidTypes = [NoCcList, CcList, BccList]

  attr_reader :cc_type, :addresses, :mailer

  def initialize(cc_type, addresses, mailer = NullMailer.new)
    @cc_type = cc_type
    @addresses = addresses
    @mailer = mailer
  end

  def on(mailer)
    self.class.new(cc_type, addresses, mailer)
  end

  def recepients
    result = {}
    result[:cc] = address_list if cc_type == CcList
    result[:bcc] = address_list if cc_type == BccList
    result
  end

  def mail(recepients)
    recepients[:cc] = address_list if cc_type == CcList
    recepients[:bcc] = address_list if cc_type == BccList
    mailer.mail(recepients)
  end

  def ==(other)
    other.class == self.class && other.cc_type == cc_type && other.addresses == addresses
  end

  private
  def address_list
    return addresses.strip unless addresses.include?(',')
    addresses.split(',').map {|address| address.strip } 
  end
end

