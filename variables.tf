variable "name" {
  description = "Name of your scheduler"
  type        = string
}

variable "timezone" {
  description = "Timezone of the scheduler"
  type        = string
  default     = "UTC"
}

variable "period" {
  description = "Period of inactivity"
  type        = string
}

variable "schedule" {
  description = "You can customize your different schedule"
  type = map(
    object({
      start = string
      stop  = string
    })
  )
  default = null
}

variable "start_time" {
  description = "Time when you start your instance"
  type        = string
  default     = "9:00"
}

variable "stop_time" {
  description = "Time when you stop your instance"
  type        = string
  default     = "18:00"
}

variable "type" {
  description = "ec2 or rds to shutdown"
  type        = string
  default     = "ec2"
}

variable "group_name" {
  description = "Group name of your scheduler"
  type        = string
  default     = "default"
}

variable "flexible_time_window" {
  description = "Define when to schedule"
  type = object({
    mode                      = optional(string, "OFF") #FLEXIBLE
    maximum_window_in_minutes = optional(number)
  })
  default = {}
}

variable "target" {
  description = "Define which target"
  type        = any
}

variable "enabled" {
  description = "enabled ?"
  type        = bool
  default     = true
}

variable "create_iam_role" {
  description = "Create iam role"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "iam role arn"
  type        = string
  default     = null
}
