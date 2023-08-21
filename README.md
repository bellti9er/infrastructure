# infrastructure
코드형 인프라(Infrastructure as Code, Iac) 도구인 Terraform을 활용하여 인프라의 형상관리를 하는 repository입니다.

</br>

#### 🚧 TODO 🚧

- Set up a VPN system in the management network and route the cicd to the private subnet using ALB and Route53.
- Build and connect API Gateway and Lambda.
- Message Queue (ex. SQS, SNS)
- Modularization

</br>

## Why use Terraform?

- 자동화
- 속도와 안전
- 문서화
- 형상관리
- 리뷰 및 테스트
- 재사용

  
</br>

## Project Directory Structures

전체적으로 아래와 같은 구조를 가지고 있습니다.

```shell
infrastructure
├── global
│   ├── iam
│   ├── s3
│   └── ...
├── scripts
│   └── ...
├── management
│   ├── services
│   │   ├── cicd
│   │   ├── vpn
│   │   ├── monitoring
│   │   └── ...
│   └── vpc
├── prod
│   ├── database
│   │   └── aurora
│   ├── services
│   │   ├── backend
│   │   └── frontend
│   └── vpc
└── staging
    ├── database
    │   └── mysql
    ├── services
    │   ├── backend
    │   └── frontend
    └── vpc
```

####  - global
- production, staging, dev 등에 모두 사용되는 system 설정 코드가 위치합니다.

#### - scirpts
- 리소스 생성 및 관리 시 사용되는 스크립트가 위치합니다. (ex. kms encrypt/decrypt)

#### - management
- 다른 infrastructure들을 관리하는 시스템들이 위치합니다.
- 여기에 위치하는 대표적인 시스템으로는 `VPN`, `CICD` 등이 있습니다.

#### - prod 
- production 시스템들이 위치합니다.

#### - staging
-  production에 배포 되기 이전의 서비스 관리 및 개발을 위한 staging 시스템들이 위치합니다.


</br>

각 하위 디렉토리들은 다음과 같은 파일을 갖고 구성되어 있습니다. 

```shell
├── services
│   ├── backend
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── locals.tf
│   │   ├── outputs.tf
│   │   └── vars.tf
```

#### - backend.tf
- 각 디렉토리가 독립된 Terraform 실행 단위이기 떄문에, 이러한 디렉토리마다 독립된 state file이 생성되고 관리되어야 합니다.
- 그래서 Terraform 상태를 저장하고 관리하기 위해 AWS S3 버킷을 활용합니다. 이는 Terraform이 관리하는 인프라의 상태를 안전하게 유지하고, 여러 개발자가 인프라를 관리할 때의 문제를 방지하는데 도움이 됩니다.

#### - main.tf
- Terraform 설정 코드 파일입니다.

#### - vars.tf
-   variables를 지정해 놓은 파일입니다.

#### - outputs.tf
- 해당 디렉토리가 Terraform에 의해 실행된 후 생성될 output들을 정의해놓은 파일입니다.

#### - locals.tf
- 복잡하거나 자주 사용되는 값을 로컬 변수로 정의해놓은 파일입니다.


</br>
</br>

### Git Commit Message Template

첨부된 `.gitmessga.txt` 파일을 사용하여 git commit message에 대한 통일된 포맷을 유지할 수 있습니다.

1. 터미널을 열고 아래의 명령어를 입력하여 git이 해당 파일을 commit message template으로써 사용하도록 설정합니다.

    ```shell
    $ git config commit.template .gitmessage.txt
    ```

    위의 명령어는 current repository에만 적용되므로, 모든 repository에서 템플릿을 사용하려면 `--global` 옵션을 추가합니다.

    ```shell
    $ git config --global commit.template .gitmessage.txt 
    ```




2. 이제 commit 명령어를 실행하면 편집기가 열리면서 `.gitmessage.txt`의 내용을 활용할 수 있습니다.

    ```shell
    $ git commit
    ```
