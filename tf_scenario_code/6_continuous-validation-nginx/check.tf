check "response_nginx" {
  data "http" "nginx" {
   url      = "http://${aws_instance.ec2.public_dns}"

  depends_on = [time_sleep.wait_15_seconds]
  # depends_on = [check.response_ec2_running]
}

  assert {
    condition     = data.http.nginx.status_code == 200
    error_message = "Nginx Status Code가 ${data.http.nginx.status_code} 으로 정상적이지 않습니다."
  }
}

check "response_ec2_running" {

  assert {
    condition     = aws_instance.ec2.instance_state == "running"
    error_message = "EC2 인스턴스가 Running 상태가 아닙니다."
  }
}

