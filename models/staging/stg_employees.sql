select *
from {{ source('hr', 'employees') }}
