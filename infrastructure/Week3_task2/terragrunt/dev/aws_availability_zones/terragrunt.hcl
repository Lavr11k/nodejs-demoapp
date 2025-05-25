include "root"{
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.modules_path}//aws_availability_zones"
}

inputs = {
  azs_amount = 2
}