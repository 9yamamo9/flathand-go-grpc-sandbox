gen-proto:
	protoc -Iproto --go_out=plugins=grpc:api proto/*.proto