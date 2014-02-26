module GHI
  module Commands
    class Pull < Command
      SUBCOMMANDS = %w{ show create edit fetch close merge }
      SUBCOMMANDS.each do |cmd|
        autoload cmd.capitalize, "ghi/commands/pull/#{cmd}"
      end

      def execute
        handle_help_request
        parse_subcommand
      end

      def handle_help_request
        if args.first.match(/--?h(elp)?/)
          abort help
        end
      end

      def help
        <<EOF
Usage: ghi pull <subcommand> <pull_request_no> [options]

----- Subcommands -----

#{SUBCOMMANDS.map { |cmd| to_const(cmd).help }.compact.join("\n")}
EOF
      end

      def parse_subcommand
        subcommand = args.shift
        if SUBCOMMANDS.include?(subcommand)
          to_const(subcommand).new(args).execute
        else
          abort "Invalid Syntax\n#{help}"
        end
      end

      private

      def pull_uri
        "/repos/#{repo}/pulls/#{issue}"
      end

      # dirty hack - this allows us to use the same format_issue
      # method as all other issues do
      def honor_the_issue_contract(pr)
        pr['pull_request'] = { 'html_url' => true }
        pr['labels'] = []
      end

      def to_const(str)
        self.class.const_get(str.capitalize)
      end

      def self.help
        new([]).options.to_s
      end
    end
  end
end