# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Base
      class Association
        class UndefinedAdapter < StandardError
          def message
            'Please, specify adapter for association level'
          end
        end

        class << self
          attr_writer :adapter

          def inherited(subclass)
            return unless defined?(@adapter)

            subclass.adapter = adapter
          end

          def adapter
            @adapter || raise(UndefinedAdapter)
          end
        end

        # Params:
        # +reflection+:: Association eflection object
        # +source+:: Instance of cloned object (ex: User.new(posts: posts))
        # +declaration+:: = Relation description
        #                   (ex: Clowne::Declarations::IncludeAssociation.new(:posts))
        # +params+:: = Instance of Hash
        def initialize(reflection, source, declaration, params)
          @source = source
          @scope = declaration.scope
          @clone_with = declaration.clone_with
          @params = params
          @association_name = declaration.name.to_s
          @reflection = reflection
          @cloner_options = declaration.params_proxy.permit(params: params, parent: source)
          @cloner_options.merge!(traits: declaration.traits) if declaration.traits
        end

        def call(_record)
          raise NotImplementedError
        end

        def association
          @_association ||= source.__send__(association_name)
        end

        def clone_one(child)
          cloner = cloner_for(child)
          cloner ? cloner.call(child, cloner_options) : dup_record(child)
        end

        def with_scope
          base_scope = init_scope
          if scope.is_a?(Symbol)
            base_scope.__send__(scope)
          elsif scope.is_a?(Proc)
            base_scope.instance_exec(params, &scope) || base_scope
          else
            base_scope
          end.to_a
        end

        private

        def dup_record(record)
          self.class.adapter.dup_record(record)
        end

        def init_scope
          raise NotImplementedError
        end

        def cloner_for(child)
          return clone_with if clone_with

          return child.class.cloner_class if child.class.respond_to?(:cloner_class)
        end

        attr_reader :source, :scope, :clone_with, :params, :association_name,
                    :reflection, :cloner_options
      end
    end
  end
end
