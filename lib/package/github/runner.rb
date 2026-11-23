# frozen_string_literal: true

require 'json'
require 'time'

module Package
  module Github
    class Runner
      include Rake::FileUtilsExt

      BRANCH = 'main'

      def initialize(platform)
        @platform = platform
      end

      def run
        workflow = "build-#{@platform}.yml"
        started_at = Time.now.utc

        puts "GitHub Actions: starting #{workflow} on #{BRANCH}..."
        start_workflow(workflow)
        puts 'GitHub Actions: waiting for the workflow run...'
        run_id = find_run(workflow, started_at)

        puts "GitHub Actions: watching run ##{run_id}..."
        watch_run(run_id)
        run_id
      end

      private

      def start_workflow(workflow)
        sh 'gh', 'workflow', 'run', workflow, '--ref', BRANCH
      end

      def find_run(workflow, started_at)
        20.times do
          runs = JSON.parse(
            `gh run list --workflow #{workflow} --branch #{BRANCH} --event workflow_dispatch --limit 10 --json databaseId,createdAt`
          )
          run = runs.find { |candidate| Time.iso8601(candidate.fetch('createdAt')) >= started_at }
          if run
            puts
            return run.fetch('databaseId')
          end

          print '.'
          $stdout.flush
          sleep 3
        end
        puts

        abort 'Could not find the GitHub Actions run'
      end

      def watch_run(run_id)
        sh 'gh', 'run', 'watch', run_id.to_s, '--exit-status'
      end
    end
  end
end
