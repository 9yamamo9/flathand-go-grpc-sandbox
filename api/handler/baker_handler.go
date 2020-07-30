package handler

import (
	"context"
	"flathand-go-grpc-sandbox/api/gen/api"
	"github.com/golang/protobuf/ptypes/timestamp"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"math/rand"
	"sync"
	"time"
)

func init() {
	rand.Seed(time.Now().UnixNano())
}

type BakerHandler struct {
	report *report
}

type report struct {
	sync.Mutex
	data map[api.Pancake_Menu]int
}

func NewBakerHandler() *BakerHandler {
	return &BakerHandler{
			report: &report{
				data:  make(map[api.Pancake_Menu]int),
			},
	}
}

func (h *BakerHandler) Bake(
		ctx context.Context,
		req *api.BakeRequest,
	) (*api.BakeResponse, error) {
	if req.Menu == api.Pancake_UNKNOWN || req.Menu > api.Pancake_SPICY_CURRY {
		return nil, status.Errorf(
			codes.InvalidArgument,
			"パンケーキを選んでください！")
	}

	now := time.Now()
	h.report.Lock()
	h.report.data[req.Menu] = h.report.data[req.Menu] + 1
	h.report.Unlock()

	return &api.BakeResponse{
		Pancake: &api.Pancake{
			ChefName:       "gami",
			Menu:           req.Menu,
			TechnicalScore: rand.Float32(),
			CreateTime:     &timestamp.Timestamp{
				Seconds: now.Unix(),
				Nanos:   int32(now.Nanosecond()),
			},
		},
	}, nil
}

func (h *BakerHandler) Report(
		ctx context.Context,
		req *api.ReportRequest,
	) (*api.ReportResponse, error) {

	counts := make([]*api.Report_BakeCount, 0)

	h.report.Lock()
	for k, v := range h.report.data {
		counts = append(counts, &api.Report_BakeCount{
			Menu:  k,
			Count: int32(v),
		})
	}
	h.report.Unlock()

	return &api.ReportResponse{
		Report: &api.Report{
			BakeCounts: counts,
		},
	}, nil
}