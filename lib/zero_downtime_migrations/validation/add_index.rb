module ZeroDowntimeMigrations
  class Validation
    class AddIndex < Validation
      def validate!
        return if primary_index_migration? || (concurrent? && migration.ddl_disabled?)
        error!(message)
      end

      private

      def message
        <<-MESSAGE.strip_heredoc
          Adding a non-concurrent index is unsafe!

          This action can lock your database table while indexing existing data!

          Instead, let's add the index concurrently in its own migration with
          the DDL transaction disabled. We can do this by inheriting Primary::IndexMigration.

          Your migration can be generated using this command:

            ./bin/rails generate primary_index_migration <Migration_Class_Name_Here>

        MESSAGE
      end

      def primary_index_migration?
        migration.class.superclass.name == 'Primary::IndexMigration'
      end

      def concurrent?
        options[:algorithm] == :concurrently
      end

      def column
        args[1]
      end

      def column_title
        Array(column).map(&:to_s).join("_and_").camelize
      end

      def table
        args[0]
      end

      def table_title
        table.to_s.camelize
      end
    end
  end
end
