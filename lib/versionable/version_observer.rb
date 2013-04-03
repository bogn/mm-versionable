module Versionable
  # Ported from collectiveidea's audited gem this class injects the currrent_user into all Version records
  # so that you don't have to call updater_id on all modification methods.
  #@see https://github.com/collectiveidea/audited/blob/250e1ba5838a6d90b69e541461ca6632b9172d4b/lib/audited/sweeper.rb
  # The name Sweeper got changed as well, as it seems to be historical, not 100% sure about that. But
  # https://github.com/collectiveidea/audited/blob/e24b8761f0204a8fd53252cac735137155eb1e72/lib/audit_sweeper.rb#L39
  # points to an implentation making use of ActionController::Caching::Sweeper which the current one doesn't.
  class VersionObserver < ActiveModel::Observer
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
      version.updater_id ||= current_user.try(:id)
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
      callback_meth = :"_notify_versioned_observer"
      klass.send(:define_method, callback_meth) do
        observer.update(:before_create, self)
      end
      klass.send(:before_create, callback_meth)
    end
  end
end

if defined?(ActionController) and defined?(ActionController::Base)
  ActionController::Base.class_eval do
    around_filter Versionable::VersionObserver.instance
  end
end
