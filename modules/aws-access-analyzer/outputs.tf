output "analyzer_arn" {
  description = "ARN of the analyzer."
  value       = aws_accessanalyzer_analyzer.this.arn
}

output "analyzer_name" {
  description = "Name of the analyzer."
  value       = aws_accessanalyzer_analyzer.this.analyzer_name
}

output "archive_rules" {
  description = "Names of the managed archive rules."
  value       = keys(aws_accessanalyzer_archive_rule.this)
}
