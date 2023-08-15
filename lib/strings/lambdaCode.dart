String lambdaCode="""
{
  "code": [
    {
      "prim": "DUP"
    },
    {
      "prim": "CAR"
    },
    {
      "prim": "CDR"
    },
    {
      "prim": "UNPACK",
      "args": [
        {
          "prim": "option",
          "args": [
            {
              "prim": "key_hash"
            }
          ]
        }
      ]
    },
    {
      "prim": "IF_NONE",
      "args": [
        [
          {
            "prim": "DROP"
          },
          {
            "prim": "PUSH",
            "args": [
              {
                "prim": "string"
              },
              {
                "string": "decoding contract delegate failed"
              }
            ]
          },
          {
            "prim": "FAILWITH"
          }
        ],
        [
          {
            "prim": "NIL",
            "args": [
              {
                "prim": "operation"
              }
            ]
          },
          {
            "prim": "SWAP"
          },
          {
            "prim": "SET_DELEGATE"
          },
          {
            "prim": "CONS"
          },
          {
            "prim": "SWAP"
          },
          {
            "prim": "CAR"
          },
          {
            "prim": "CAR"
          },
          {
            "prim": "NONE",
            "args": [
              {
                "prim": "address"
              }
            ]
          },
          {
            "prim": "PAIR"
          },
          {
            "prim": "PAIR"
          }
        ]
      ]
    }
  ],
  "handler_check": [
    {
      "prim": "DROP"
    },
    {
      "prim": "UNIT"
    }
  ],
  "is_active": true
}
""";