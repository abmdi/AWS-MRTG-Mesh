# Fetch Available Availability Zones for Region A
data "aws_availability_zones" "primary_az" {
  provider = aws.us_east_1
  state    = "available"
}

# Fetch Available Availability Zones for Region B
data "aws_availability_zones" "secondary_az" {
  provider = aws.eu_west_1
  state    = "available"
}
