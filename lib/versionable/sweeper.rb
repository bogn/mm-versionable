module Versionable
  # Ported from collectiveidea's audited gem this class injects the currrent_user into all Version records
  # so that you don't have to call updater_id on all modification methods.
  # The name Sweeper got ported as well, not 100% it still applies. Maybe this except from the changelog helps:
  # 2006-11-17 - Replaced use of singleton User.current_user with cache sweeper implementation for auditing the user that made the change
  #@see https://github.com/collectiveidea/audited/blob/250e1ba5838a6d90b69e541461ca6632b9172d4b/lib/audited/sweeper.rb
  class Sweeper < ActiveModel::Observer
    observe Version

    attr_accessor :controller

    def before(controller)
      self.controller = controller
      true
    end

    def after(controller)
      self.controller = nil
    end

    def before_create(version)
      version.updater_id ||= current_user.id
    end

    def current_user
      controller.send(Versionable.current_user_method) if controller.respond_to?(Versionable.current_user_method, true)
    end

    def add_observer!(klass)
      super
      define_callback(klass)
    end

    def define_callback(klass)
      observer = self
      callback_meth = :"_notify_versioned_sweeper"
      klass.send(:define_method, callback_meth) do
        observer.update(:before_create, self)
      end
      klass.send(:before_create, callback_meth)
    end
  end
end

if defined?(ActionController) and defined?(ActionController::Base)
  ActionController::Base.class_eval do
    around_filter Versionable::Sweeper.instance
  end
end
