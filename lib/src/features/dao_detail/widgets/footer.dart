import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
bool werule=true;
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700; // threshold for switching layout

    return Container(
      width: width,
      color: const Color.fromARGB(255, 25, 25, 25),
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _linksSection(),
        _logoSection(),
        _creditsSection(),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _logoSection(),
        const SizedBox(height: 24),
        _linksSection(),
        const SizedBox(height: 24),
        _creditsSection(),
      ],
    );
  }

  Widget _linksSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {},
          child: const Text(
            'Terms',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () {},
          child: const Text(
            'Privacy',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () {},
          child: const Text(
            'Contact',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _logoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.7)),
          child: 
        werule?  
          Logo():Brand(),
        ),
        const SizedBox(height: 18),
        Text(
          '© ${DateTime.now().year}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _creditsSection() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Powered by ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            InkWell(
              onTap: () {},
              child: const Text(
                'Tezos Commons',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Developed by ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            InkWell(
              onTap: () {},
              child: const Text(
                'Eight Rice',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) {
    if (werule){
      return Logo();
    }else{
      return const LogoHB();
    }
  }
}
class LogoHB extends StatelessWidget {
  const LogoHB({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () => context.go("/"),
      child:  Row(
      mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
      children: [
          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Image.network("https://i.ibb.co/qLYBbs8v/hblogo.png", height: 32,),
          ),
          const SizedBox(width: 8),
          SizedBox(height: 45,
            child: Center(
              child: const Text(
              "Homebase",
              style: TextStyle(
                fontSize: 20
              )
              ),
            ),
          )
      ],
      )
    );
  }
}



class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () => context.go("/"),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'we',
            style: TextStyle(
              fontFamily: 'CascadiaCode',
              backgroundColor: Color.fromARGB(255, 192, 192, 192),
              fontSize: 28,
              color: Color.fromARGB(255, 22, 22, 22),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: 2),
          Text(
            'R',
            style: TextStyle(
              fontFamily: 'CascadiaCode',
              backgroundColor: Color.fromARGB(255, 26, 26, 26),
              fontSize: 24,
              fontWeight: FontWeight.w100,
            ),
          ),
          Text(
            'ule',
            style: TextStyle(
              fontFamily: 'CascadiaCode',
              backgroundColor: Color.fromARGB(255, 26, 26, 26),
              fontSize: 28,
              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      ),
    );
  }
}
