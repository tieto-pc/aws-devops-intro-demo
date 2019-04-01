# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.


module "codecommit" {
  source          = "../codecommit"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  region          = "${var.region}"
}


module "codebuild" {
  source          = "../codebuild"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  region          = "${var.region}"
}

