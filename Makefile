gen-proto:
	protoc -Iproto --go_out=plugins=grpc:api proto/*.proto
	bundle exec grpc_tools_ruby_protoc -I proto --ruby_out=api/gen/api/pancake/maker --grpc_out=api/gen/api/pancake/maker proto/pancake.proto

setup:
	dep ensure