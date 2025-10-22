<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BaseResource extends JsonResource
{
    public $status;
    public $message;
    public $httpCode;
    
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function __construct($status, $message, $resource, int $httpCode = 200)
    {
        parent::__construct($resource);
        $this->status = $status;
        $this->message = $message;
        $this->httpCode = $httpCode;
    }

    public function toArray(Request $request): array
    {
        return [
            'status' => $this->status,
            'message' => $this->message,
            'data' => $this->resource,
        ];
    }

    public function withResponse($request, $response)
    {
        $response->setStatusCode($this->httpCode);
    }
}
