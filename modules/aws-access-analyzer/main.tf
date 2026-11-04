# External-access analyzer. Findings are free; unused-access analysis is a
# separate, paid analyzer type and is not created by this module.
resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = var.analyzer_name
  type          = var.type
  tags          = var.tags
}

resource "aws_accessanalyzer_archive_rule" "this" {
  for_each = var.archive_rules

  analyzer_name = aws_accessanalyzer_analyzer.this.analyzer_name
  rule_name     = each.key

  dynamic "filter" {
    for_each = each.value
    content {
      criteria = filter.value.criteria
      eq       = filter.value.eq
      neq      = filter.value.neq
      contains = filter.value.contains
      exists   = filter.value.exists == null ? null : tostring(filter.value.exists)
    }
  }
}
