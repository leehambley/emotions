require 'emotions/version'
require 'singleton'
require 'redis'

module Emotions

  class << self
    attr_accessor :backend
  end

  module KeyBuilderExtensions

    def generate_key(scope, id = nil)
      [self.class.name, scope, id].compact.join(':')
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
        tcn = @target.class == Class ? @target.name : @target.class.name
        key += ":#{tcn}"
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
    private :write_key

    def read_key(key_name)
      redis.get(key_name)
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

  class KeyLoader

    def initialize(key)
      @object_class, @emotion, @object_id, @target_class = key.split(':')
    end

    def object
      Object.const_get(@object_class).find(object_id)
    end

    private

      def object_id
        @object_id.to_i == @object_id ? @object_id : @object_id.to_i
      end

  end

  class Emotion

    attr_accessor :target, :object, :emotion, :created_at

    def initialize(args = {})
      @target, @object, @emotion, @created_at =
        args.fetch(:target), args.fetch(:object), args.fetch(:emotion), args.fetch(:created_at, nil)
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

    def ==(other_emotion)
      emotion_equal  = self.emotion == other_emotion.emotion
      emotion_target = self.target  == other_emotion.target
      emotion_object = self.object  == other_emotion.object
      emotion_equal && emotion_target && emotion_object
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
         self.class.send :define_method, :"#{emotion}_emotes" do
           lookup_key_builder = KeyBuilder.new(object: self, emotion: emotion)
           keys = Emotions.backend.keys_matching(lookup_key_builder.key + "*")
           keys.collect do |key_name|
             key_loader = KeyLoader.new(key_name)
             Emotion.new(target: true, emotion: true, object: key_loader.object)
           end
         end
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
