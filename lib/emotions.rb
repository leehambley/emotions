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

  module KeyBuilderExtensions

    def generate_key(scope, id = nil)
      cn = self.class.name.dup
      cn.class.send(:include, StringExtensions)
      [cn.underscore, scope, id].compact.join(':')
    end

  end

  class KeyBuilder

    def initialize(args)
      @object  = args.fetch(:object)
      @target  = args.fetch(:target, nil)
      @emotion = args.fetch(:emotion)
    end

    def key
      object = @object.dup
      object.class.send(:include, KeyBuilderExtensions)
      key = object.generate_key(@emotion, object.id)
      if @target
        tcn = @target.class == Class ? @target.name.dup : @target.class.name.dup
        tcn.class.send(:include, StringExtensions)
        key += ":#{tcn.underscore}"
      end
      key
    end

  end

  class RedisBackend

    attr_accessor :redis

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

    def read_sub_key(key_name, key)
      redis.hget(key_name, key)
    end

    def remove_sub_keys(key_pairs)
      redis.multi do
        key_pairs.each do |key_name, key|
          redis.hdel(key_name, key.to_s)
        end
      end
    end

    def keys_matching(argument)
      redis.keys(argument)
    end

  end

  class Emotion

    attr_accessor :target, :object, :emotion

    def initialize(args = {})
      @target, @object, @emotion =
        args.fetch(:target), args.fetch(:object), args.fetch(:emotion)
    end

    def persist(args = {time: Time.now})
      backend.write_keys({
        target_key => {object.id.to_s => args.fetch(:time)},
        object_key => {target.id.to_s => args.fetch(:time)},
      })
    end

    def object_key
      KeyBuilder.new(object: object, emotion: emotion, target: target).key
    end

    def target_key
      KeyBuilder.new(object: target, emotion: emotion, target: object).key
    end

    def exists?
      tk = backend.read_sub_key(target_key, object.id.to_s)
      ok = backend.read_sub_key(object_key, target.id.to_s)
      tk && ok
    end

    def remove
      backend.remove_sub_keys([[target_key, object.id.to_s],
                               [object_key, target.id.to_s]])
    end


    private

      def backend
        Emotions.backend
      end

  end

  module Emotive

    class << self

      def included(klass)
        klass.send(:include, InstanceMethods)
        klass.send(:extend,  ClassMethods)
      end

    end

    module ClassMethods
      def emotions(*emotions)
        emotions.each { |emotion| register_emotion(emotion.to_sym) }
      end
      def register_emotion(name)
        @registered_emotions ||= Array.new
        @registered_emotions <<  name
      end
      def registered_emotions
        @registered_emotions
      end
    end

    module InstanceMethods

      def initialize(*args)
        super
        self.class.registered_emotions.each do |emotion|
          self.class.send :define_method, :"#{emotion}_by" do |*args|
            emotional, time = *args
            time  ||= Time.now.utc
            e = Emotion.new(object: emotional, target: self, emotion: emotion)
            true & e.persist(time: time)
          end
          self.class.send :define_method, :"cancel_#{emotion}_by" do |emotional|
            Emotion.new(object: emotional, target: self, emotion: emotion).remove
          end
#         self.class.send :define_method, :"#{emotion}_emotes" do
#           lookup_key_builder = KeyBuilder.new(object: self, emotion: emotion)
#           keys = Emotions.backend.keys_matching(lookup_key_builder.key + "*")
#           puts "REDIS HAS #{Emotions.backend.redis.get(keys)}"
#         end
        end
      end

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
