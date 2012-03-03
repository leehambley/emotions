require 'emotions/version'
require 'singleton'
require 'redis'

module Emotions

  class << self
    attr_accessor :backend
  end

  module StringExtensions
    def underscore(delimiter = ':')
      c = dup
      c.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      c.gsub!(/\:\:/, delimiter)
      c.downcase!
      c
    end
  end

  class KeyBuilder
    attr_reader :object, :target
    private :object, :target
    def initialize(object, extras = {})
      raise ArgumentError, "Object must not be nil" if object.nil?
      @object  = object
      @emotion = extras.fetch(:emotion, nil)
      @target  = extras.fetch(:target, nil)
      if (@emotion and @target.nil?) or (@target and @emotion.nil?)
        raise ArgumentError, "Cannot generate an emotion key without a target"  
      end
    end
    def key
      if target
        [underscore_object_class_name, _object_id, emotion, 
         underscore_target_class_name, target_id].compact.join(delimiter)
      else
        [underscore_object_class_name, _object_id].compact.join(delimiter)
      end
    end
    private
      def emotion
        @emotion ? @emotion.to_s : nil
      end
      def underscore_emotion
        return nil unless emotion
        e = emotion.dup
        e.class.send(:include, StringExtensions)
        e.underscore(delimiter)
      end
      def _object_id
        object.id.to_s
      end
      def target_id
        target ? target.id.to_s : nil
      end
      def object_class_name
        object.class.name
      end
      def underscore_object_class_name
        cn = object_class_name.dup
        cn.class.send(:include, StringExtensions)
        cn.underscore(delimiter)
      end
      def target_class_name
        return nil unless target
        target.class.name
      end
      def underscore_target_class_name
        return nil unless target
        cn = target_class_name.dup
        cn.class.send(:include, StringExtensions)
        cn.underscore(delimiter)
      end
      def delimiter
        ':'
      end
  end

  class RedisBackend

    attr_accessor :redis

    def key_exists?(key_name)
      redis.exists(key_name)
    end

    def write_keys(key_hashes)
      redis.multi do
        key_hashes.each do |key_name, hash|
          write_key(key_name, hash)
        end  
      end
    end

    def write_key(key_name, hash)
      hash.each do |hash_key, hash_value|
        redis.hset key_name, hash_key, hash_value
      end
    end

    def read_key(key_name)
      Hash[reids.hgetall(key_name)]
    end

  end

  class Emotion

    attr_accessor :target, :object, :emotion

    def initialize(args = {})
      @target, @object, @emotion = args.fetch(:target), args.fetch(:object), args.fetch(:emotion)
    end

    def persist(args = {time: Time.now})
      backend.write_keys({
        target_key => {created_at: args.fetch(:time)},
        object_key => {created_at: args.fetch(:time)},
      })
    end

    def object_key
      KeyBuilder.new(object, emotion: emotion, target: target).key
    end
    
    def target_key
      KeyBuilder.new(target, emotion: emotion, target: object).key
    end

    def exists?
      backend.key_exists?(target_key)
    end

    private

      def backend
        Emotions.backend
      end
    
  end

  module Emotive

    class << self

      attr_accessor :_emotions

      def included(klass)
        klass.send(:include, InstanceMethods)
        klass.send(:extend,  ClassMethods)
      end

    end

    module ClassMethods
      def emotions(*emotions)
        emotions.each { |emotion| emotion(emotion) }
      end
      def emotion(name)

      end
    end
  
    module InstanceMethods

    end

  end

  module Emotional

    def self.included(klass)
      klass.send(:include, InstanceMethods)
      klass.send(:extend,  ClassMethods)
    end

    module ClassMethods

    end
  
    module InstanceMethods

    end

  end

end
